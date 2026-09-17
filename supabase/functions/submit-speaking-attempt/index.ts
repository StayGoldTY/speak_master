import { corsHeaders } from '../_shared/cors.ts';
import { createUserClient } from '../_shared/supabase-client.ts';
import {
  analyzeTranscript,
  buildFallbackPackage,
} from '../_shared/speech-utils.ts';
import { transcribeAudio } from '../_shared/openai.ts';
import {
  assessPronunciationWithAzure,
  azureSupportsMimeType,
  hasAzureSpeech,
  type AzurePronunciationAssessment,
} from '../_shared/azure-pronunciation.ts';

type SubmitSpeakingAttemptRequest = {
  promptId?: string;
  activityKind?: string;
  accentPreference?: string;
  referenceText?: string;
  focusWords?: string[];
  transcriptHint?: string;
  audioBase64?: string | null;
  audioMimeType?: string | null;
  audioFilename?: string | null;
  audioDurationMs?: number | null;
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return jsonResponse({ error: 'Method not allowed.' }, 405);
  }

  try {
    const payload = (await req.json()) as SubmitSpeakingAttemptRequest;
    const promptId = payload.promptId?.trim();
    const activityKind = payload.activityKind?.trim();
    const accentPreference = payload.accentPreference?.trim() || 'american';
    const referenceText = payload.referenceText?.trim();
    const focusWords = payload.focusWords ?? [];
    const locale = accentPreference === 'british' ? 'en-GB' : 'en-US';

    if (!promptId || !activityKind || !referenceText) {
      return jsonResponse(
        { error: 'promptId, activityKind, and referenceText are required.' },
        400,
      );
    }

    const supabase = createUserClient(req);
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser();

    if (authError || !user) {
      return jsonResponse({ error: 'Unauthorized.' }, 401);
    }

    let azure: AzurePronunciationAssessment | null = null;
    let recognizedText = payload.transcriptHint?.trim() ?? '';
    let transcriptSource: 'cloud_stt' | 'local_hint' | 'azure_pa' = 'local_hint';

    if (
      payload.audioBase64 &&
      hasAzureSpeech() &&
      azureSupportsMimeType(payload.audioMimeType ?? '')
    ) {
      azure = await assessPronunciationWithAzure({
        audioBase64: payload.audioBase64,
        audioMimeType: payload.audioMimeType ?? 'audio/wav',
        referenceText,
        locale,
      });
      if (azure?.recognizedText) {
        recognizedText = azure.recognizedText;
        transcriptSource = 'azure_pa';
      }
    }

    if (!recognizedText && payload.audioBase64) {
      try {
        const cloudTranscript = await transcribeAudio({
          audioBase64: payload.audioBase64,
          audioMimeType: payload.audioMimeType ?? 'audio/webm',
          audioFilename: payload.audioFilename ?? 'attempt.webm',
          referenceText,
        });
        if (cloudTranscript) {
          recognizedText = cloudTranscript;
          transcriptSource = 'cloud_stt';
        }
      } catch (_) {
        // Whisper is only a transcript fallback, never a score source.
      }
    }

    if (!recognizedText && !azure) {
      return jsonResponse(
        { error: 'No usable transcript was produced for the attempt.' },
        422,
      );
    }

    const analysis = analyzeTranscript({
      referenceText,
      transcript: recognizedText || azure?.recognizedText || '',
      focusWords,
      audioDurationMs: payload.audioDurationMs,
    });

    const speechPackage = azure
      ? buildAzurePackage({ azure, promptId })
      : buildFallbackPackage({ analysis, promptId });

    const feedback = azure
      ? {
          recognizedText: azure.recognizedText || analysis.recognizedText,
          coverageScore: clamp(azure.completenessScore / 100, 0, 1),
          fluencyBand: speechPackage.feedback.fluencyBand ?? analysis.fluencyBand,
          paceBand: analysis.paceBand,
          stressHints: speechPackage.feedback.stressHints,
          weakWords: speechPackage.feedback.weakWords,
          retrySuggestions: speechPackage.feedback.retrySuggestions,
          teacherExplanation: speechPackage.feedback.teacherExplanation,
          fallbackUsed: false,
          weakPointTags: speechPackage.feedback.weakPointTags,
          generatedAt: new Date().toISOString(),
          assessmentKind: 'azure_acoustic',
          accuracyScore: azure.accuracyScore,
          fluencyScore: azure.fluencyScore,
          completenessScore: azure.completenessScore,
          pronScore: azure.pronScore,
          wordResults: azure.words.map((word) => ({
            word: word.word,
            errorType: (word.errorType || 'none').toLowerCase(),
            accuracyScore: word.accuracyScore,
          })),
          phonemeIssues: azure.words.flatMap((word) =>
            word.phonemes
              .filter((phoneme) => phoneme.accuracyScore < 60)
              .map((phoneme) => ({
                expected: phoneme.phoneme,
                spoken: phoneme.spokenPhoneme,
                accuracyScore: phoneme.accuracyScore,
              })),
          ),
        }
      : {
          recognizedText: analysis.recognizedText,
          coverageScore: analysis.coverageScore,
          fluencyBand: analysis.fluencyBand,
          paceBand: analysis.paceBand,
          stressHints: speechPackage.feedback.stressHints,
          weakWords: speechPackage.feedback.weakWords,
          retrySuggestions: speechPackage.feedback.retrySuggestions,
          teacherExplanation: speechPackage.feedback.teacherExplanation,
          fallbackUsed: true,
          weakPointTags: speechPackage.feedback.weakPointTags,
          generatedAt: new Date().toISOString(),
          assessmentKind: 'recognition_alignment',
          wordResults: [],
          phonemeIssues: [],
        };

    const {
      data: attemptRow,
      error: attemptError,
    } = await supabase
      .from('speaking_attempts')
      .insert({
        user_id: user.id,
        prompt_id: promptId,
        activity_kind: activityKind,
        reference_text: referenceText,
        recognized_text: feedback.recognizedText,
        coverage_score: feedback.coverageScore,
        fluency_band: feedback.fluencyBand,
        pace_band: feedback.paceBand,
        stress_hints: feedback.stressHints,
        weak_words: feedback.weakWords,
        retry_suggestions: feedback.retrySuggestions,
        teacher_explanation: feedback.teacherExplanation,
        fallback_used: feedback.fallbackUsed,
        weak_point_tags: feedback.weakPointTags,
        attempt_source: azure ? 'cloud' : 'local_fallback',
        accent_preference: accentPreference,
        transcript_source:
          transcriptSource === 'azure_pa' ? 'cloud_stt' : transcriptSource,
        audio_duration_ms: payload.audioDurationMs,
      })
      .select('id, created_at')
      .single();

    if (attemptError) {
      throw attemptError;
    }

    const {
      data: reportRow,
      error: reportError,
    } = await supabase
      .from('assessment_reports')
      .insert({
        user_id: user.id,
        source_attempt_id: attemptRow.id,
        overall_label: speechPackage.report.overallLabel,
        overview: speechPackage.report.overview,
        weak_targets: speechPackage.report.weakTargets,
        next_steps: speechPackage.report.nextSteps,
        recommended_route: '/session',
        attempt_source: azure ? 'cloud' : 'local_fallback',
      })
      .select('id, created_at')
      .single();

    if (reportError) {
      throw reportError;
    }

    const reviewItems = (speechPackage.reviewItems as Array<{
      label: string;
      reason: string;
      recommendedActivityKind: string;
      score: number;
    }>).map((item) => ({
      ...item,
      source_key: `${promptId}:${item.label}`,
    }));

    if (reviewItems.length > 0) {
      const sourceKeys = reviewItems.map((item) => item.source_key);

      await supabase
        .from('review_queue')
        .delete()
        .eq('user_id', user.id)
        .in('source_key', sourceKeys)
        .is('completed_at', null);

      await supabase.from('review_queue').insert(
        reviewItems.map((item) => ({
          user_id: user.id,
          label: item.label,
          reason: item.reason,
          recommended_activity_kind: item.recommendedActivityKind,
          score: item.score,
          source_key: item.source_key,
        })),
      );
    }

    return jsonResponse({
      attempt: {
        id: attemptRow.id,
        promptId,
        activityKind,
        accentPreference,
        transcriptSource,
        audioDurationMs: payload.audioDurationMs,
        source: azure ? 'cloud' : 'local_fallback',
        feedback,
        createdAt: attemptRow.created_at,
      },
      assessmentReport: {
        id: reportRow.id,
        overallLabel: speechPackage.report.overallLabel,
        overview: speechPackage.report.overview,
        weakTargets: speechPackage.report.weakTargets,
        nextSteps: speechPackage.report.nextSteps,
        recommendedRoute: '/session',
        source: azure ? 'cloud' : 'local_fallback',
        createdAt: reportRow.created_at,
      },
      reviewItems: reviewItems.map((item) => ({
        id: item.source_key,
        label: item.label,
        reason: item.reason,
        recommendedActivityKind: item.recommendedActivityKind,
        score: item.score,
      })),
    });
  } catch (error) {
    return jsonResponse(
      {
        error: error instanceof Error ? error.message : 'Unexpected error.',
      },
      500,
    );
  }
});

const jsonResponse = (body: Record<string, unknown>, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json',
    },
  });

const clamp = (value: number, min: number, max: number) =>
  Math.min(max, Math.max(min, value));

const buildAzurePackage = ({
  azure,
  promptId,
}: {
  azure: AzurePronunciationAssessment;
  promptId: string;
}) => {
  const weakWords = azure.words
    .filter((word) => {
      if (['Omission', 'Mispronunciation'].includes(word.errorType)) {
        return true;
      }
      return (word.accuracyScore ?? 100) < 70;
    })
    .map((word) => word.word)
    .filter(Boolean)
    .slice(0, 4);

  const phonemeTags = azure.words.flatMap((word) =>
    word.phonemes
      .filter((phoneme) => phoneme.accuracyScore < 60)
      .map((phoneme) => ({
        label: phoneme.phoneme,
        type: 'phoneme' as const,
        reason: `Azure scored /${phoneme.phoneme}/ at ${Math.round(phoneme.accuracyScore)}.`,
      })),
  );

  const weakPointTags = [
    ...weakWords.map((word) => ({
      label: word,
      type: 'word' as const,
      reason: 'Azure marked this word as omitted, mispronounced, or low accuracy.',
    })),
    ...phonemeTags,
  ].slice(0, 4);

  const teacherExplanation =
    `这是 Azure 声学评测，不是识别覆盖率。综合分 ${Math.round(azure.pronScore)}，准确度 ${Math.round(azure.accuracyScore)}，流利度 ${Math.round(azure.fluencyScore)}，完整度 ${Math.round(azure.completenessScore)}。` +
    (weakWords.length
      ? `需要盯住 ${weakWords.join(', ')}。`
      : '词级准确度目前比较稳。');

  const fluencyBand =
    azure.pronScore >= 80
      ? 'confident'
      : azure.pronScore >= 60
      ? 'steady'
      : 'emerging';

  return {
    feedback: {
      fluencyBand,
      stressHints: [
        `综合发音分 ${Math.round(azure.pronScore)}（准确 ${Math.round(azure.accuracyScore)} / 流利 ${Math.round(azure.fluencyScore)} / 完整 ${Math.round(azure.completenessScore)}）。`,
      ],
      weakWords,
      retrySuggestions: weakWords.length
        ? [`先单练 ${weakWords.slice(0, 2).join(' / ')}，再回到整句。`]
        : ['把同一句再读一遍，保持当前节奏。'],
      teacherExplanation,
      weakPointTags,
    },
    report: {
      overallLabel:
        azure.pronScore >= 80
          ? '声学评分可以进入下一轮'
          : azure.pronScore >= 60
          ? '声学评分还要再收一收'
          : '先把低分词和音素补上',
      overview: teacherExplanation,
      weakTargets: weakPointTags,
      nextSteps: [
        ...(weakWords.length
          ? [`先把 ${weakWords[0]} 单练后再连回整句。`]
          : ['同一句再读一遍，保持节奏。']),
        '听一遍标准音，再按自然语速复读。',
      ],
      recommendedRoute: '/session',
    },
    reviewItems: weakPointTags.map((tag, index) => ({
      id: `${promptId}:${index}:${tag.label}`,
      label: tag.label,
      reason: tag.reason,
      recommendedActivityKind:
        tag.type === 'phoneme' ? 'phoneme_intro' : 'word_repeat',
      score: Math.round(100 - azure.pronScore),
    })),
  };
};
