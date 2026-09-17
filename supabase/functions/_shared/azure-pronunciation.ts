export type AzurePronunciationPhoneme = {
  phoneme: string;
  accuracyScore: number;
  spokenPhoneme?: string;
};

export type AzurePronunciationWord = {
  word: string;
  accuracyScore?: number;
  errorType: string;
  phonemes: AzurePronunciationPhoneme[];
};

export type AzurePronunciationAssessment = {
  recognizedText: string;
  accuracyScore: number;
  fluencyScore: number;
  completenessScore: number;
  pronScore: number;
  locale: string;
  words: AzurePronunciationWord[];
};

const azureSpeechKey = Deno.env.get('AZURE_SPEECH_KEY')?.trim() ?? '';
const azureSpeechRegion = Deno.env.get('AZURE_SPEECH_REGION')?.trim() ?? '';

export const hasAzureSpeech = () =>
  azureSpeechKey.length > 0 && azureSpeechRegion.length > 0;

export const azureSupportsMimeType = (mimeType: string) => {
  const normalized = mimeType.toLowerCase();
  if (normalized.includes('webm')) {
    return false;
  }
  return (
    normalized.includes('wav') ||
    normalized.includes('pcm') ||
    ((normalized.includes('ogg') || normalized.includes('opus')) &&
      !normalized.includes('webm'))
  );
};

const contentTypeForMime = (mimeType: string) => {
  const normalized = mimeType.toLowerCase();
  if (normalized.includes('wav') || normalized.includes('pcm')) {
    return 'audio/wav; codecs=audio/pcm; samplerate=16000';
  }
  if (
    (normalized.includes('ogg') || normalized.includes('opus')) &&
    !normalized.includes('webm')
  ) {
    return 'audio/ogg; codecs=opus';
  }
  return null;
};

export const assessPronunciationWithAzure = async ({
  audioBase64,
  audioMimeType,
  referenceText,
  locale,
}: {
  audioBase64: string;
  audioMimeType: string;
  referenceText: string;
  locale: string;
}): Promise<AzurePronunciationAssessment | null> => {
  if (!hasAzureSpeech() || !audioBase64 || !referenceText.trim()) {
    return null;
  }

  const contentType = contentTypeForMime(audioMimeType);
  if (!contentType) {
    return null;
  }

  const params = JSON.stringify({
    ReferenceText: referenceText.trim(),
    GradingSystem: 'HundredMark',
    Granularity: 'Phoneme',
    Dimension: 'Comprehensive',
    EnableMiscue: 'True',
    EnableProsodyAssessment: 'True',
    PhonemeAlphabet: 'IPA',
    NBestPhonemeCount: '3',
  });
  const header = btoa(params);
  const url = new URL(
    `https://${azureSpeechRegion}.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1`,
  );
  url.searchParams.set('language', locale);
  url.searchParams.set('format', 'detailed');

  const bytes = Uint8Array.from(atob(audioBase64), (char) => char.charCodeAt(0));
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Ocp-Apim-Subscription-Key': azureSpeechKey,
      'Content-Type': contentType,
      Accept: 'application/json',
      'Pronunciation-Assessment': header,
    },
    body: bytes,
  });

  if (!response.ok) {
    throw new Error(`Azure pronunciation assessment failed: ${await response.text()}`);
  }

  const payload = await response.json();
  return parseAzurePronunciation(payload, locale);
};

export const parseAzurePronunciation = (
  payload: Record<string, unknown>,
  locale: string,
): AzurePronunciationAssessment | null => {
  const nBest = payload.NBest;
  const best =
    Array.isArray(nBest) && nBest[0] && typeof nBest[0] === 'object'
      ? (nBest[0] as Record<string, unknown>)
      : null;
  const assessmentRaw = best?.PronunciationAssessment;
  if (!assessmentRaw || typeof assessmentRaw !== 'object') {
    return null;
  }

  const assessment = assessmentRaw as Record<string, unknown>;
  const wordsRaw = best?.Words;
  const words: AzurePronunciationWord[] = [];
  if (Array.isArray(wordsRaw)) {
    for (const item of wordsRaw) {
      if (!item || typeof item !== 'object') {
        continue;
      }
      words.push(parseWord(item as Record<string, unknown>));
    }
  }

  const displayText =
    payload.DisplayText?.toString() ?? best?.Display?.toString() ?? '';

  return {
    recognizedText: displayText.trim(),
    accuracyScore: asNumber(assessment.AccuracyScore),
    fluencyScore: asNumber(assessment.FluencyScore),
    completenessScore: asNumber(assessment.CompletenessScore),
    pronScore: asNumber(assessment.PronScore ?? assessment.AccuracyScore),
    locale,
    words,
  };
};

const parseWord = (raw: Record<string, unknown>): AzurePronunciationWord => {
  const assessment =
    raw.PronunciationAssessment && typeof raw.PronunciationAssessment === 'object'
      ? (raw.PronunciationAssessment as Record<string, unknown>)
      : {};
  const phonemes: AzurePronunciationPhoneme[] = [];
  if (Array.isArray(raw.Phonemes)) {
    for (const item of raw.Phonemes) {
      if (!item || typeof item !== 'object') {
        continue;
      }
      phonemes.push(parsePhoneme(item as Record<string, unknown>));
    }
  }

  return {
    word: raw.Word?.toString() ?? '',
    accuracyScore:
      assessment.AccuracyScore == null
        ? undefined
        : asNumber(assessment.AccuracyScore),
    errorType: assessment.ErrorType?.toString() ?? 'None',
    phonemes,
  };
};

const parsePhoneme = (
  raw: Record<string, unknown>,
): AzurePronunciationPhoneme => {
  const assessment =
    raw.PronunciationAssessment && typeof raw.PronunciationAssessment === 'object'
      ? (raw.PronunciationAssessment as Record<string, unknown>)
      : {};
  let spoken: string | undefined;
  const nBest = assessment.NBestPhonemes;
  if (Array.isArray(nBest) && nBest[0] && typeof nBest[0] === 'object') {
    spoken = (nBest[0] as Record<string, unknown>).Phoneme?.toString();
  }

  return {
    phoneme: raw.Phoneme?.toString() ?? '',
    accuracyScore: asNumber(assessment.AccuracyScore),
    spokenPhoneme: spoken,
  };
};

const asNumber = (value: unknown) => {
  if (typeof value === 'number') {
    return value;
  }
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : 0;
};
