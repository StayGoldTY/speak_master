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
  const expectedWords = uniqueTokens(tokenize(referenceText));
  const spokenWords = uniqueTokens(tokenize(transcript));
  const normalizedFocusWords = uniqueTokens(
    focusWords.flatMap((item) => tokenize(item)),
  );

  const matchedWords = expectedWords.filter((word) => spokenWords.includes(word));
  const missingWords = expectedWords
    .filter((word) => !spokenWords.includes(word))
    .slice(0, 8);
  const matchedFocusWords = normalizedFocusWords.filter((word) =>
    spokenWords.includes(word),
  );
  const missingFocusWords = normalizedFocusWords.filter(
    (word) => !spokenWords.includes(word),
  );
  const weakWords = Array.from(
    new Set([...missingFocusWords, ...missingWords]),
  ).slice(0, 5);

  const coverageScore =
    expectedWords.length === 0
      ? 0
      : clamp(matchedWords.length / expectedWords.length, 0, 1);
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
    matchedWords,
    missingWords,
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
    `Coverage is ${Math.round(analysis.coverageScore * 100)}%.`,
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
