import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/pronunciation_check_engine.dart';
import '../../../services/pronunciation_practice_service.dart';
import '../../../services/recording_upload_payload.dart';
import '../../domain/models/course_models.dart';
import '../../domain/models/learner_models.dart';
import '../../domain/models/speech_models.dart';
import 'local_assessment_report_builder.dart';
import 'speech_feedback_engine.dart';

class V2SpeechAssessmentService {
  final SupabaseClient? _client;
  final SpeechFeedbackEngine _feedbackEngine;
  final LocalAssessmentReportBuilder _reportBuilder;

  const V2SpeechAssessmentService({
    required SupabaseClient? client,
    required SpeechFeedbackEngine feedbackEngine,
    required LocalAssessmentReportBuilder reportBuilder,
  }) : _client = client,
       _feedbackEngine = feedbackEngine,
       _reportBuilder = reportBuilder;

  Future<SpeakingAssessmentResult> submitAttempt({
    required SpeakingPrompt prompt,
    required String accentPreference,
    required PronunciationCheckResult localResult,
    LearnerRecording? learnerRecording,
  }) async {
    final fallback = buildLocalFallback(
      prompt: prompt,
      accentPreference: accentPreference,
      localResult: localResult,
      learnerRecording: learnerRecording,
    );

    final client = _client;
    if (client == null || client.auth.currentUser == null) {
      return fallback;
    }

    try {
      final uploadPayload = learnerRecording == null
          ? null
          : await loadRecordingUploadPayload(learnerRecording.path);

      final response = await client.functions.invoke(
        'submit-speaking-attempt',
        body: {
          'promptId': prompt.id,
          'activityKind': _activityKindKey(prompt.kind),
          'accentPreference': accentPreference,
          'referenceText': prompt.referenceText,
          'focusWords': prompt.focusWords,
          'transcriptHint': localResult.transcript,
          'audioBase64': uploadPayload == null
              ? null
              : base64Encode(uploadPayload.bytes),
          'audioMimeType': uploadPayload?.mimeType,
          'audioFilename': uploadPayload?.filename,
          'audioDurationMs': learnerRecording?.duration.inMilliseconds,
        },
      );

      return _mapFunctionResult(_asMap(response.data));
    } catch (_) {
      return fallback;
    }
  }

  SpeakingAssessmentResult buildLocalFallback({
    required SpeakingPrompt prompt,
    required String accentPreference,
    required PronunciationCheckResult localResult,
    LearnerRecording? learnerRecording,
  }) {
    final feedback = _feedbackEngine.build(
      result: localResult,
      focusWords: prompt.focusWords,
      fallbackUsed: true,
    );
    final report = _reportBuilder.build(
      feedback: feedback,
      recommendedRoute: '/speaking',
    );
    final reviewItems = _reportBuilder.buildReviewItems(
      feedback: feedback,
      promptId: prompt.id,
    );

    return SpeakingAssessmentResult(
      attempt: SpeakingAttemptRecord(
        promptId: prompt.id,
        activityKind: prompt.kind,
        accentPreference: accentPreference,
        transcriptSource: 'local_hint',
        audioDurationMs: learnerRecording?.duration.inMilliseconds,
        source: SpeechAttemptSource.localFallback,
        feedback: feedback,
        createdAt: feedback.generatedAt,
      ),
      report: report,
      reviewItems: reviewItems,
    );
  }

  Future<List<SpeakingAttemptRecord>> loadRecentAttempts({
    required SpeakingPrompt prompt,
    int limit = 5,
  }) async {
    final client = _client;
    if (client == null || client.auth.currentUser == null) {
      return const [];
    }

    try {
      final rows = await client
          .from('speaking_attempts')
          .select(
            'id, prompt_id, recognized_text, reference_text, coverage_score, '
            'fluency_band, pace_band, stress_hints, weak_words, '
            'retry_suggestions, teacher_explanation, fallback_used, '
            'weak_point_tags, created_at, attempt_source, accent_preference, '
            'transcript_source, audio_duration_ms, activity_kind',
          )
          .eq('prompt_id', prompt.id)
          .order('created_at', ascending: false)
          .limit(limit);

      return (rows as List<dynamic>)
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (row) => _mapAttemptRow(
              row.map((key, value) => MapEntry(key.toString(), value)),
              fallbackPrompt: prompt,
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  SpeakingAssessmentResult _mapFunctionResult(Map<String, dynamic> data) {
    final attemptData = _asMap(data['attempt']);
    final feedbackData = _asMap(attemptData['feedback']);
    final reportData = _asMap(data['assessmentReport']);
    final reviewItemsData = (data['reviewItems'] as List<dynamic>? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (item) => item.map((key, value) => MapEntry(key.toString(), value)),
        )
        .toList();

    final feedback = SpeechFeedback.fromMap(feedbackData);

    return SpeakingAssessmentResult(
      attempt: SpeakingAttemptRecord(
        id: attemptData['id']?.toString(),
        promptId: attemptData['promptId']?.toString() ?? '',
        activityKind: _activityKindFromKey(
          attemptData['activityKind']?.toString(),
        ),
        accentPreference:
            attemptData['accentPreference']?.toString() ?? 'american',
        transcriptSource:
            attemptData['transcriptSource']?.toString() ?? 'local_hint',
        audioDurationMs: (attemptData['audioDurationMs'] as num?)?.toInt(),
        source: SpeechAttemptSourceX.fromKey(attemptData['source']?.toString()),
        feedback: feedback,
        createdAt:
            DateTime.tryParse(attemptData['createdAt']?.toString() ?? '') ??
            feedback.generatedAt,
      ),
      report: SpeechAssessmentReport(
        id: reportData['id']?.toString(),
        overallLabel: reportData['overallLabel']?.toString() ?? '',
        overview: reportData['overview']?.toString() ?? '',
        weakTargets: (reportData['weakTargets'] as List<dynamic>? ?? const [])
            .whereType<Map<dynamic, dynamic>>()
            .map(
              (item) => WeakPointTag.fromMap(
                item.map((key, value) => MapEntry(key.toString(), value)),
              ),
            )
            .toList(),
        nextSteps: (reportData['nextSteps'] as List<dynamic>? ?? const [])
            .map((item) => item.toString())
            .toList(),
        recommendedRoute: reportData['recommendedRoute']?.toString(),
        source: SpeechAttemptSourceX.fromKey(reportData['source']?.toString()),
        createdAt:
            DateTime.tryParse(reportData['createdAt']?.toString() ?? '') ??
            DateTime.now(),
      ),
      reviewItems: reviewItemsData.map(_mapReviewItem).toList(),
    );
  }

  SpeakingAttemptRecord _mapAttemptRow(
    Map<String, dynamic> row, {
    required SpeakingPrompt fallbackPrompt,
  }) {
    return SpeakingAttemptRecord(
      id: row['id']?.toString(),
      promptId: row['prompt_id']?.toString() ?? fallbackPrompt.id,
      activityKind: _activityKindFromKey(
        row['activity_kind']?.toString(),
        fallback: fallbackPrompt.kind,
      ),
      accentPreference: row['accent_preference']?.toString() ?? 'american',
      transcriptSource: row['transcript_source']?.toString() ?? 'local_hint',
      audioDurationMs: (row['audio_duration_ms'] as num?)?.toInt(),
      source: SpeechAttemptSourceX.fromKey(row['attempt_source']?.toString()),
      feedback: SpeechFeedback(
        recognizedText: row['recognized_text']?.toString() ?? '',
        coverageScore: (row['coverage_score'] as num?)?.toDouble() ?? 0,
        fluencyBand: FluencyBandX.fromKey(row['fluency_band']?.toString()),
        paceBand: PaceBandX.fromKey(row['pace_band']?.toString()),
        stressHints: (row['stress_hints'] as List<dynamic>? ?? const [])
            .map((item) => item.toString())
            .toList(),
        weakWords: (row['weak_words'] as List<dynamic>? ?? const [])
            .map((item) => item.toString())
            .toList(),
        retrySuggestions:
            (row['retry_suggestions'] as List<dynamic>? ?? const [])
                .map((item) => item.toString())
                .toList(),
        teacherExplanation: row['teacher_explanation']?.toString() ?? '',
        fallbackUsed: row['fallback_used'] == true,
        weakPointTags: (row['weak_point_tags'] as List<dynamic>? ?? const [])
            .whereType<Map<dynamic, dynamic>>()
            .map(
              (item) => WeakPointTag.fromMap(
                item.map((key, value) => MapEntry(key.toString(), value)),
              ),
            )
            .toList(),
        generatedAt:
            DateTime.tryParse(row['created_at']?.toString() ?? '') ??
            DateTime.now(),
      ),
      createdAt:
          DateTime.tryParse(row['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  ReviewItem _mapReviewItem(Map<String, dynamic> map) {
    return ReviewItem(
      id: map['id']?.toString() ?? '',
      label: map['label']?.toString() ?? '',
      reason: map['reason']?.toString() ?? '',
      recommendedActivityKind: _activityKindFromKey(
        map['recommendedActivityKind']?.toString(),
      ),
      score: (map['score'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    throw StateError('Expected a JSON object from speech assessment.');
  }

  ActivityKind _activityKindFromKey(
    String? value, {
    ActivityKind fallback = ActivityKind.assessmentTask,
  }) {
    return ActivityKind.values.firstWhere(
      (item) => _activityKindKey(item) == value,
      orElse: () => fallback,
    );
  }

  String _activityKindKey(ActivityKind kind) {
    return switch (kind) {
      ActivityKind.phonemeIntro => 'phoneme_intro',
      ActivityKind.minimalPair => 'minimal_pair',
      ActivityKind.wordRepeat => 'word_repeat',
      ActivityKind.sentenceReadAloud => 'sentence_read_aloud',
      ActivityKind.shadowing => 'shadowing',
      ActivityKind.dialogRoleplay => 'dialog_roleplay',
      ActivityKind.dictation => 'dictation',
      ActivityKind.mcq => 'mcq',
      ActivityKind.speakingReflection => 'speaking_reflection',
      ActivityKind.assessmentTask => 'assessment_task',
    };
  }
}
