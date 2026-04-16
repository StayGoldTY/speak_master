export const speechAssessmentSchema = {
  name: 'speech_assessment_package',
  strict: true,
  schema: {
    type: 'object',
    additionalProperties: false,
    required: ['feedback', 'report', 'reviewItems'],
    properties: {
      feedback: {
        type: 'object',
        additionalProperties: false,
        required: [
          'stressHints',
          'weakWords',
          'retrySuggestions',
          'teacherExplanation',
          'weakPointTags',
        ],
        properties: {
          stressHints: {
            type: 'array',
            items: { type: 'string' },
            minItems: 1,
            maxItems: 3,
          },
          weakWords: {
            type: 'array',
            items: { type: 'string' },
            maxItems: 6,
          },
          retrySuggestions: {
            type: 'array',
            items: { type: 'string' },
            minItems: 1,
            maxItems: 4,
          },
          teacherExplanation: {
            type: 'string',
          },
          weakPointTags: {
            type: 'array',
            maxItems: 5,
            items: {
              type: 'object',
              additionalProperties: false,
              required: ['label', 'type', 'reason'],
              properties: {
                label: { type: 'string' },
                type: {
                  type: 'string',
                  enum: ['phoneme', 'word', 'rhythm', 'stress', 'linkedSpeech'],
                },
                reason: { type: 'string' },
              },
            },
          },
        },
      },
      report: {
        type: 'object',
        additionalProperties: false,
        required: [
          'overallLabel',
          'overview',
          'weakTargets',
          'nextSteps',
          'recommendedRoute',
        ],
        properties: {
          overallLabel: { type: 'string' },
          overview: { type: 'string' },
          weakTargets: {
            type: 'array',
            maxItems: 4,
            items: {
              type: 'object',
              additionalProperties: false,
              required: ['label', 'type', 'reason'],
              properties: {
                label: { type: 'string' },
                type: {
                  type: 'string',
                  enum: ['phoneme', 'word', 'rhythm', 'stress', 'linkedSpeech'],
                },
                reason: { type: 'string' },
              },
            },
          },
          nextSteps: {
            type: 'array',
            items: { type: 'string' },
            minItems: 2,
            maxItems: 4,
          },
          recommendedRoute: {
            type: 'string',
            enum: ['/speaking', '/learn', '/progress'],
          },
        },
      },
      reviewItems: {
        type: 'array',
        maxItems: 4,
        items: {
          type: 'object',
          additionalProperties: false,
          required: ['label', 'reason', 'recommendedActivityKind', 'score'],
          properties: {
            label: { type: 'string' },
            reason: { type: 'string' },
            recommendedActivityKind: {
              type: 'string',
              enum: [
                'phoneme_intro',
                'minimal_pair',
                'word_repeat',
                'sentence_read_aloud',
                'shadowing',
                'dialog_roleplay',
                'dictation',
                'mcq',
                'speaking_reflection',
                'assessment_task',
              ],
            },
            score: {
              type: 'number',
            },
          },
        },
      },
    },
  },
} as const;
