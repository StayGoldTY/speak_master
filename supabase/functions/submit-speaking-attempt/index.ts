import { corsHeaders } from '../_shared/cors.ts';
import { createUserClient } from '../_shared/supabase-client.ts';
import {
  analyzeTranscript,
  buildFallbackPackage,
} from '../_shared/speech-utils.ts';
import {
  generateSpeechAssessment,
  transcribeAudio,
} from '../_shared/openai.ts';

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

    let recognizedText = payload.transcriptHint?.trim() ?? '';
    let transcriptSource: 'cloud_stt' | 'local_hint' = 'local_hint';

    if (payload.audioBase64) {
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
    }

    if (!recognizedText) {
      return jsonResponse(
        { error: 'No usable transcript was produced for the attempt.' },
        422,
      );
    }

    const analysis = analyzeTranscript({
      referenceText,
      transcript: recognizedText,
      focusWords,
      audioDurationMs: payload.audioDurationMs,
    });

    let speechPackage;
    try {
      speechPackage = await generateSpeechAssessment({
        promptId,
        activityKind,
        accentPreference,
        referenceText,
        focusWords,
        transcriptSource,
        analysis,
      });
    } catch (_) {
      speechPackage = buildFallbackPackage({ analysis, promptId });
    }

    const feedback = {
      recognizedText: analysis.recognizedText,
      coverageScore: analysis.coverageScore,
      fluencyBand: analysis.fluencyBand,
      paceBand: analysis.paceBand,
      stressHints: speechPackage.feedback.stressHints,
      weakWords: speechPackage.feedback.weakWords,
      retrySuggestions: speechPackage.feedback.retrySuggestions,
      teacherExplanation: speechPackage.feedback.teacherExplanation,
      fallbackUsed: false,
      weakPointTags: speechPackage.feedback.weakPointTags,
      generatedAt: new Date().toISOString(),
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
        fallback_used: false,
        weak_point_tags: feedback.weakPointTags,
        attempt_source: 'cloud',
        accent_preference: accentPreference,
        transcript_source: transcriptSource,
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
        recommended_route: speechPackage.report.recommendedRoute,
        attempt_source: 'cloud',
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
        source: 'cloud',
        feedback,
        createdAt: attemptRow.created_at,
      },
      assessmentReport: {
        id: reportRow.id,
        overallLabel: speechPackage.report.overallLabel,
        overview: speechPackage.report.overview,
        weakTargets: speechPackage.report.weakTargets,
        nextSteps: speechPackage.report.nextSteps,
        recommendedRoute: speechPackage.report.recommendedRoute,
        source: 'cloud',
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
