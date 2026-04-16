import { speechAssessmentSchema } from './speech-schema.ts';
import type { RuleAnalysis } from './speech-utils.ts';

const openAiApiKey = Deno.env.get('OPENAI_API_KEY');

const openAiHeaders = () => {
  if (!openAiApiKey) {
    throw new Error('OPENAI_API_KEY is missing.');
  }

  return {
    Authorization: `Bearer ${openAiApiKey}`,
  };
};

export const transcribeAudio = async ({
  audioBase64,
  audioMimeType,
  audioFilename,
  referenceText,
}: {
  audioBase64: string;
  audioMimeType: string;
  audioFilename: string;
  referenceText: string;
}) => {
  const formData = new FormData();
  const bytes = Uint8Array.from(atob(audioBase64), (char) =>
    char.charCodeAt(0),
  );

  formData.append(
    'file',
    new Blob([bytes], { type: audioMimeType || 'audio/webm' }),
    audioFilename || 'attempt.webm',
  );
  formData.append('model', 'gpt-4o-mini-transcribe');
  formData.append('prompt', referenceText);

  const response = await fetch('https://api.openai.com/v1/audio/transcriptions', {
    method: 'POST',
    headers: openAiHeaders(),
    body: formData,
  });

  if (!response.ok) {
    throw new Error(`OpenAI transcription failed: ${await response.text()}`);
  }

  const payload = await response.json();
  return payload.text?.toString().trim() ?? '';
};

export const generateSpeechAssessment = async ({
  promptId,
  activityKind,
  accentPreference,
  referenceText,
  focusWords,
  transcriptSource,
  analysis,
}: {
  promptId: string;
  activityKind: string;
  accentPreference: string;
  referenceText: string;
  focusWords: string[];
  transcriptSource: string;
  analysis: RuleAnalysis;
}) => {
  const response = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      ...openAiHeaders(),
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: 'gpt-4o-mini',
      temperature: 0.4,
      messages: [
        {
          role: 'system',
          content:
            'You are a pronunciation coach for adult Chinese English learners. Base the feedback only on the provided transcript and rule analysis. Do not claim acoustic scoring or hidden phoneme detection. Keep the advice concrete, honest, short, and practice-oriented.',
        },
        {
          role: 'user',
          content: JSON.stringify({
            promptId,
            activityKind,
            accentPreference,
            transcriptSource,
            referenceText,
            focusWords,
            analysis,
            rules: {
              weakWordsMustComeFrom: analysis.weakWords,
              recommendedRouteAllowedValues: ['/speaking', '/learn', '/progress'],
            },
          }),
        },
      ],
      response_format: {
        type: 'json_schema',
        json_schema: speechAssessmentSchema,
      },
    }),
  });

  if (!response.ok) {
    throw new Error(`OpenAI structured output failed: ${await response.text()}`);
  }

  const payload = await response.json();
  const content = payload.choices?.[0]?.message?.content;
  if (typeof content !== 'string') {
    throw new Error('OpenAI structured output returned an empty message.');
  }

  return JSON.parse(content);
};
