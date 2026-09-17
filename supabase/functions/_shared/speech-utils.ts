export type WeakPointTagType =
  | 'phoneme'
  | 'word'
  | 'rhythm'
  | 'stress'
  | 'linkedSpeech';

export type WeakPointTag = {
  label: string;
  type: WeakPointTagType;
  reason: string;
};

export type RuleAnalysis = {
  recognizedText: string;
  coverageScore: number;
  fluencyBand: 'emerging' | 'steady' | 'confident';
  paceBand: 'tooSlow' | 'balanced' | 'tooFast';
  expectedWords: string[];
  spokenWords: string[];
  matchedWords: string[];
  missingWords: string[];
  matchedFocusWords: string[];
  missingFocusWords: string[];
  weakWords: string[];
  estimatedWordsPerMinute: number | null;
};

export type AlignedWord = {
  expected: string;
  spoken: string;
  status: 'match' | 'substitute' | 'missing' | 'extra';
};

export const alignWords = (expected: string[], spoken: string[]) => {
  const rows = expected.length;
  const cols = spoken.length;
  const table = Array.from({ length: rows + 1 }, () =>
    Array.from({ length: cols + 1 }, () => 0),
  );

  for (let row = 0; row <= rows; row += 1) {
    table[row][0] = row;
  }
  for (let col = 0; col <= cols; col += 1) {
    table[0][col] = col;
  }
  for (let row = 1; row <= rows; row += 1) {
    for (let col = 1; col <= cols; col += 1) {
      const cost = expected[row - 1] === spoken[col - 1] ? 0 : 1;
      table[row][col] = Math.min(
        table[row - 1][col] + 1,
        table[row][col - 1] + 1,
        table[row - 1][col - 1] + cost,
      );
    }
  }

  const alignments: AlignedWord[] = [];
  let row = rows;
  let col = cols;
  while (row > 0 || col > 0) {
    if (
      row > 0 &&
      col > 0 &&
      expected[row - 1] === spoken[col - 1] &&
      table[row][col] === table[row - 1][col - 1]
    ) {
      alignments.push({
        expected: expected[row - 1],
        spoken: spoken[col - 1],
        status: 'match',
      });
      row -= 1;
      col -= 1;
      continue;
    }
    if (row > 0 && col > 0 && table[row][col] === table[row - 1][col - 1] + 1) {
      alignments.push({
        expected: expected[row - 1],
        spoken: spoken[col - 1],
        status: 'substitute',
      });
      row -= 1;
      col -= 1;
      continue;
    }
    if (col > 0 && table[row][col] === table[row][col - 1] + 1) {
      alignments.push({
        expected: '',
        spoken: spoken[col - 1],
        status: 'extra',
      });
      col -= 1;
      continue;
    }
    alignments.push({
      expected: expected[row - 1],
      spoken: '',
      status: 'missing',
    });
    row -= 1;
  }

  alignments.reverse();
  const matchedWords = alignments
    .filter((item) => item.status === 'match')
    .map((item) => item.expected);
  const missingWords = alignments
    .filter(
      (item) => item.status === 'missing' || item.status === 'substitute',
    )
    .map((item) => item.expected);

  return {
    alignments,
    matchedWords,
    missingWords,
    coverage:
      expected.length === 0
        ? 0
        : clamp(matchedWords.length / expected.length, 0, 1),
  };
};

export const analyzeTranscript = ({
  referenceText,
  transcript,
  focusWords,
  audioDurationMs,
}: {
  referenceText: string;
  transcript: string;
  focusWords: string[];
  audioDurationMs?: number | null;
}): RuleAnalysis => {
  const expectedWords = tokenize(referenceText);
  const spokenWords = tokenize(transcript);
  const alignment = alignWords(expectedWords, spokenWords);
  const spokenSet = new Set(spokenWords);
  const normalizedFocusWords = uniqueTokens(
    focusWords.flatMap((item) => tokenize(item)),
  );

  const matchedFocusWords = normalizedFocusWords.filter((word) =>
    spokenSet.has(word),
  );
  const missingFocusWords = normalizedFocusWords.filter(
    (word) => !spokenSet.has(word),
  );
  const weakWords = Array.from(
    new Set([...missingFocusWords, ...alignment.missingWords]),
  ).slice(0, 5);

  const coverageScore = alignment.coverage;
  const estimatedWordsPerMinute =
    audioDurationMs && audioDurationMs > 0
      ? Math.round((spokenWords.length / audioDurationMs) * 60000)
      : null;

  const fluencyBand =
    coverageScore >= 0.85
      ? 'confident'
      : coverageScore >= 0.58
      ? 'steady'
      : 'emerging';
  const paceBand =
    estimatedWordsPerMinute == null
      ? 'balanced'
      : estimatedWordsPerMinute > 175
      ? 'tooFast'
      : estimatedWordsPerMinute < 75
      ? 'tooSlow'
      : 'balanced';

  return {
    recognizedText: transcript.trim(),
    coverageScore,
    fluencyBand,
    paceBand,
    expectedWords,
    spokenWords,
    matchedWords: alignment.matchedWords,
    missingWords: alignment.missingWords.slice(0, 8),
    matchedFocusWords,
    missingFocusWords,
    weakWords,
    estimatedWordsPerMinute,
  };
};

export const buildFallbackPackage = ({
  analysis,
  promptId,
}: {
  analysis: RuleAnalysis;
  promptId: string;
}) => {
  const weakPointTags: WeakPointTag[] = [
    ...analysis.weakWords.map((word) => ({
      label: word,
      type: 'word' as const,
      reason: 'This word was not stably recognized in the latest attempt.',
    })),
    ...(analysis.paceBand === 'balanced'
      ? []
      : [
          {
            label: 'pace',
            type: 'rhythm' as const,
            reason: 'The overall pacing was less stable than the target line.',
          },
        ]),
  ].slice(0, 4);

  const teacherExplanation = [
    `Word-level recognition alignment is ${Math.round(analysis.coverageScore * 100)}%. This is not an acoustic pronunciation score.`,
    analysis.paceBand === 'tooFast'
      ? 'The pacing is currently a little fast.'
      : analysis.paceBand === 'tooSlow'
      ? 'The pacing is currently a little segmented.'
      : 'The pacing is currently in a healthy range.',
    analysis.weakWords.length === 0
      ? 'Most target words were recognized.'
      : `Focus next on ${analysis.weakWords.join(', ')}.`,
  ].join(' ');

  return {
    feedback: {
      stressHints:
        analysis.matchedFocusWords.length > 0
          ? [
              `Keep the main weight on ${analysis.matchedFocusWords
                .slice(0, 3)
                .join(', ')}.`,
            ]
          : ['Keep the content words slightly longer than the connectors.'],
      weakWords: analysis.weakWords,
      retrySuggestions: [
        ...(analysis.weakWords.length > 0
          ? [`Retry with extra clarity on ${analysis.weakWords.join(', ')}.`]
          : ['Repeat the line once more without changing the rhythm.']),
        ...(analysis.paceBand === 'tooFast'
          ? ['Slow down slightly so each stressed word lands cleanly.']
          : []),
        ...(analysis.paceBand === 'tooSlow'
          ? ['Keep the line connected and avoid over-separating each word.']
          : []),
      ].slice(0, 3),
      teacherExplanation,
      weakPointTags,
    },
    report: {
      overallLabel:
        analysis.coverageScore >= 0.85
          ? 'Ready to progress'
          : analysis.coverageScore >= 0.58
          ? 'Keep tightening the line'
          : 'Rebuild this target once more',
      overview: teacherExplanation,
      weakTargets: weakPointTags,
      nextSteps: [
        ...(analysis.weakWords.length > 0
          ? [`Rebuild ${analysis.weakWords[0]} in isolation before repeating the full line.`]
          : ['Repeat the same line once more and keep the rhythm equally stable.']),
        'Listen once, then repeat in one connected chunk.',
      ],
      recommendedRoute: '/speaking',
    },
    reviewItems: weakPointTags.map((tag, index) => ({
      id: `${promptId}:${index}:${tag.label}`,
      label: tag.label,
      reason: tag.reason,
      recommendedActivityKind:
        tag.type === 'rhythm' || tag.type === 'linkedSpeech'
          ? 'shadowing'
          : tag.type === 'stress'
          ? 'sentence_read_aloud'
          : tag.type === 'phoneme'
          ? 'phoneme_intro'
          : 'word_repeat',
      score: Math.round((1 - analysis.coverageScore) * 100),
    })),
  };
};

const tokenize = (value: string) => {
  return value
    .toLowerCase()
    .replaceAll("'", '')
    .replaceAll(/[^a-z0-9\s-]/g, ' ')
    .replaceAll(/\s+/g, ' ')
    .trim()
    .split(' ')
    .filter((item) => item.length > 1 || item === 'a' || item === 'i');
};

const uniqueTokens = (values: string[]) => Array.from(new Set(values));

const clamp = (value: number, min: number, max: number) =>
  Math.min(max, Math.max(min, value));
