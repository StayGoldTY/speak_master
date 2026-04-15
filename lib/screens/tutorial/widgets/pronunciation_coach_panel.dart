import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/lesson.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/service_providers.dart';
import '../../../services/pronunciation_check_engine.dart';
import '../../../services/pronunciation_practice_service.dart';
import '../../../widgets/record_button.dart';

enum PronunciationCoachMode { audioReference, guidedRepeat, readAloud }

class PronunciationCoachPanel extends ConsumerStatefulWidget {
  final LessonStep? step;
  final String? panelId;
  final String? referenceText;
  final List<String>? focusWords;
  final String? title;
  final String? description;
  final String? emptyReferenceText;
  final Color accentColor;
  final PronunciationCoachMode mode;
  final ValueChanged<PronunciationCheckResult>? onCheckCompleted;

  const PronunciationCoachPanel({
    super.key,
    this.step,
    this.panelId,
    this.referenceText,
    this.focusWords,
    this.title,
    this.description,
    this.emptyReferenceText,
    this.onCheckCompleted,
    required this.accentColor,
    required this.mode,
  }) : assert(
         step != null || panelId != null,
         'Provide step or panelId for stable widget keys.',
       ),
       assert(
         step != null || referenceText != null,
         'Provide step or referenceText so the coach has content to read.',
       );

  @override
  ConsumerState<PronunciationCoachPanel> createState() =>
      _PronunciationCoachPanelState();
}

class _PronunciationCoachPanelState
    extends ConsumerState<PronunciationCoachPanel> {
  late final PronunciationPracticeService _practiceService;
  StreamSubscription<void>? _recordingPlaybackCompletedSubscription;
  Timer? _recordingTimer;

  bool _isSpeaking = false;
  bool _isListening = false;
  bool _isRecordingLearnerVoice = false;
  bool _isPlayingLearnerRecording = false;
  bool _didFinalizeCurrentSession = false;

  Duration _recordingElapsed = Duration.zero;
  String _transcript = '';
  String? _statusMessage;
  String? _errorMessage;
  LearnerRecording? _learnerRecording;
  PronunciationCheckResult? _checkResult;

  String get _panelId => widget.step?.id ?? widget.panelId!;

  String get _referenceText =>
      widget.referenceText?.trim() ??
      (widget.step == null
          ? ''
          : PronunciationCheckEngine.buildReferenceText(widget.step!));

  List<String> get _focusWords {
    final customFocusWords = widget.focusWords
        ?.map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (customFocusWords != null && customFocusWords.isNotEmpty) {
      return customFocusWords;
    }
    if (widget.step != null) {
      return PronunciationCheckEngine.extractFocusWords(widget.step!);
    }
    return PronunciationCheckEngine.extractFocusWordsFromText(_referenceText);
  }

  String get _accentPreference {
    final authState = ref.read(authProvider);
    final storage = ref.read(storageServiceProvider);
    return authState.profile?.accentPreference ??
        storage.loadAccentPreference(fallback: 'american');
  }

  String get _panelTitle {
    if (widget.title != null && widget.title!.trim().isNotEmpty) {
      return widget.title!.trim();
    }
    return switch (widget.mode) {
      PronunciationCoachMode.audioReference => '先听标准参考，再开口跟读',
      PronunciationCoachMode.guidedRepeat => '跟读并做自动检查',
      PronunciationCoachMode.readAloud => '朗读后做自动检查',
    };
  }

  String get _panelDescription {
    if (widget.description != null && widget.description!.trim().isNotEmpty) {
      return widget.description!.trim();
    }
    return '这里会先播放系统标准发音，再提供真实录音、回放对照和浏览器识别检查。';
  }

  String get _recordingElapsedLabel {
    final totalSeconds = _recordingElapsed.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    _practiceService = PronunciationPracticeService();
    _recordingPlaybackCompletedSubscription = _practiceService
        .recordingPlaybackCompleted
        .listen((_) {
          if (!mounted) {
            return;
          }
          setState(() {
            _isPlayingLearnerRecording = false;
            _statusMessage = '你的录音回放完成，可以再听一次标准发音做对照。';
          });
        });
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _recordingPlaybackCompletedSubscription?.cancel();
    _practiceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentLabel = _accentPreference == 'british' ? '英式' : '美式';
    final hasReferenceText = _referenceText.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Divider(height: 1),
        const SizedBox(height: 20),
        _SectionHeader(
          title: _panelTitle,
          icon: Icons.graphic_eq_rounded,
          color: widget.accentColor,
        ),
        const SizedBox(height: 12),
        Text(
          '当前参考口音：$accentLabel。$_panelDescription',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.65,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              onPressed: hasReferenceText ? _toggleReferencePlayback : null,
              icon: Icon(
                _isSpeaking
                    ? Icons.stop_circle_outlined
                    : Icons.volume_up_rounded,
              ),
              label: Text(_isSpeaking ? '停止参考音' : '播放标准发音'),
            ),
            FilledButton.icon(
              key: ValueKey('speech-voice-record-$_panelId'),
              onPressed: hasReferenceText ? _toggleLearnerRecording : null,
              style: FilledButton.styleFrom(
                backgroundColor: _isRecordingLearnerVoice
                    ? AppColors.errorRed
                    : widget.accentColor,
              ),
              icon: Icon(
                _isRecordingLearnerVoice
                    ? Icons.stop_circle_outlined
                    : Icons.fiber_manual_record_rounded,
              ),
              label: Text(
                _isRecordingLearnerVoice ? '停止并保存录音' : '录自己的声音',
              ),
            ),
            OutlinedButton.icon(
              onPressed: _learnerRecording == null
                  ? null
                  : _toggleLearnerRecordingPlayback,
              icon: Icon(
                _isPlayingLearnerRecording
                    ? Icons.stop_circle_outlined
                    : Icons.play_circle_outline_rounded,
              ),
              label: Text(
                _isPlayingLearnerRecording ? '停止回放录音' : '回放我的录音',
              ),
            ),
            OutlinedButton.icon(
              onPressed:
                  hasReferenceText || _transcript.isNotEmpty || _checkResult != null
                      ? _resetCheck
                      : null,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('清空本轮反馈'),
            ),
          ],
        ),
        if (hasReferenceText) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              borderRadius: BorderRadius.circular(18),
            ),
            child: SelectionArea(
              child: Text(
                _referenceText,
                key: ValueKey('speech-reference-$_panelId'),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.65,
                ),
              ),
            ),
          ),
        ] else ...[
          const SizedBox(height: 14),
          _InfoBox(
            backgroundColor: AppColors.bgLight,
            textColor: AppColors.textSecondary,
            icon: Icons.menu_book_outlined,
            text:
                widget.emptyReferenceText ?? '当前这一步还没有可朗读的参考文本。',
          ),
        ],
        if (_focusWords.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _focusWords
                .map(
                  (word) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: widget.accentColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      word,
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.accentColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
        if (_isRecordingLearnerVoice) ...[
          const SizedBox(height: 16),
          _InfoBox(
            backgroundColor: AppColors.errorRed.withValues(alpha: 0.08),
            textColor: AppColors.errorRed,
            icon: Icons.mic_rounded,
            text: '正在录你的跟读声音：$_recordingElapsedLabel。读完整句后再点击“停止并保存录音”。',
          ),
        ],
        if (_learnerRecording != null) ...[
          const SizedBox(height: 16),
          _LearnerRecordingCard(
            panelId: _panelId,
            recording: _learnerRecording!,
            isPlaying: _isPlayingLearnerRecording,
            onTogglePlayback: _toggleLearnerRecordingPlayback,
            onClear: _clearLearnerRecording,
          ),
        ],
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              RecordButton(
                isRecording: _isListening,
                onTap: hasReferenceText && !_isRecordingLearnerVoice
                    ? _toggleRecognition
                    : () {},
              ),
              const SizedBox(height: 12),
              Text(
                _isListening
                    ? '识别中，读完整句后再点一次停止。'
                    : _isRecordingLearnerVoice
                    ? '请先结束你的录音，再开始自动识别检查。'
                    : hasReferenceText
                    ? '点击开始跟读识别，自动检查会告诉你哪些词还没有稳定读出来。'
                    : '补充参考文本后即可开始跟读识别。',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (_statusMessage != null) ...[
          const SizedBox(height: 14),
          _InfoBox(
            backgroundColor: widget.accentColor.withValues(alpha: 0.08),
            textColor: widget.accentColor,
            icon: Icons.info_outline,
            text: _statusMessage!,
          ),
        ],
        if (_errorMessage != null) ...[
          const SizedBox(height: 14),
          _InfoBox(
            backgroundColor: AppColors.errorRed.withValues(alpha: 0.08),
            textColor: AppColors.errorRed,
            icon: Icons.error_outline,
            text: _errorMessage!,
          ),
        ],
        if (_transcript.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionHeader(
            title: '识别到的内容',
            icon: Icons.subtitles_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              _transcript,
              key: ValueKey('speech-transcript-$_panelId'),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.65,
              ),
            ),
          ),
        ],
        if (_checkResult != null) ...[
          const SizedBox(height: 18),
          _AutomaticCheckCard(
            result: _checkResult!,
            accentColor: widget.accentColor,
            panelId: _panelId,
          ),
        ],
        const SizedBox(height: 18),
        const _InfoBox(
          backgroundColor: AppColors.bgLight,
          textColor: AppColors.textSecondary,
          icon: Icons.shield_moon_outlined,
          text:
              '这里已经有真实的标准发音、真实录音和真实回放；自动检查仍基于浏览器语音识别，只负责告诉你“有没有把目标词句读出来”，不是声学发音评分。',
        ),
      ],
    );
  }

  Future<void> _toggleReferencePlayback() async {
    if (_referenceText.isEmpty) {
      return;
    }
    if (_isRecordingLearnerVoice) {
      setState(() {
        _statusMessage = '请先停止你的录音，再播放标准发音。';
      });
      return;
    }

    if (_isSpeaking) {
      await _practiceService.stopSpeaking();
      if (!mounted) {
        return;
      }
      setState(() {
        _isSpeaking = false;
        _statusMessage = '标准发音已停止。';
      });
      return;
    }

    if (_isPlayingLearnerRecording) {
      await _practiceService.stopLearnerRecordingPlayback();
      if (!mounted) {
        return;
      }
      setState(() {
        _isPlayingLearnerRecording = false;
      });
    }

    setState(() {
      _isSpeaking = true;
      _errorMessage = null;
      _statusMessage = '正在播放标准参考发音。';
    });

    try {
      await _practiceService.speakReference(
        text: _referenceText,
        accentPreference: _accentPreference,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _statusMessage = '参考发音播放完成，可以立刻录自己的声音或做识别检查。';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = '当前环境暂时无法播放参考发音，请稍后重试。';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
    }
  }

  Future<void> _toggleLearnerRecording() async {
    if (_referenceText.isEmpty) {
      return;
    }

    if (_isRecordingLearnerVoice) {
      await _stopLearnerRecording();
      return;
    }

    if (_isListening) {
      await _finalizeRecognitionAfterManualStop();
    }

    if (_isSpeaking) {
      await _practiceService.stopSpeaking();
    }
    if (_isPlayingLearnerRecording) {
      await _practiceService.stopLearnerRecordingPlayback();
    }

    setState(() {
      _isSpeaking = false;
      _isPlayingLearnerRecording = false;
      _recordingElapsed = Duration.zero;
      _errorMessage = null;
      _statusMessage = '正在启动真实录音，请完整读一遍后再停止保存。';
    });

    try {
      final started = await _practiceService.startLearnerRecording();
      if (!mounted) {
        return;
      }
      if (!started) {
        setState(() {
          _errorMessage = '浏览器没有授权麦克风，暂时无法录下你的跟读。';
          _statusMessage = null;
        });
        return;
      }

      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _recordingElapsed += const Duration(seconds: 1);
        });
      });

      setState(() {
        _isRecordingLearnerVoice = true;
        _learnerRecording = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = '当前环境暂时无法开始录音，请检查浏览器权限后重试。';
        _statusMessage = null;
      });
    }
  }

  Future<void> _stopLearnerRecording() async {
    _recordingTimer?.cancel();

    try {
      final recording = await _practiceService.stopLearnerRecording(
        duration: _recordingElapsed,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _isRecordingLearnerVoice = false;
        _learnerRecording = recording;
        _statusMessage = recording == null
            ? '录音已结束，但这次没有拿到可回放的音频。'
            : '你的跟读录音已保存到当前会话，可以马上回放对照。';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isRecordingLearnerVoice = false;
        _errorMessage = '停止录音时出现问题，请稍后再试。';
      });
    }
  }

  Future<void> _toggleLearnerRecordingPlayback() async {
    final recording = _learnerRecording;
    if (recording == null) {
      return;
    }
    if (_isRecordingLearnerVoice) {
      setState(() {
        _statusMessage = '请先结束当前录音，再回放自己的声音。';
      });
      return;
    }

    if (_isPlayingLearnerRecording) {
      await _practiceService.stopLearnerRecordingPlayback();
      if (!mounted) {
        return;
      }
      setState(() {
        _isPlayingLearnerRecording = false;
        _statusMessage = '已停止回放你的录音。';
      });
      return;
    }

    if (_isSpeaking) {
      await _practiceService.stopSpeaking();
    }

    setState(() {
      _isSpeaking = false;
      _isPlayingLearnerRecording = true;
      _errorMessage = null;
      _statusMessage = '正在回放你的跟读录音。';
    });

    try {
      await _practiceService.playLearnerRecording(recording.path);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isPlayingLearnerRecording = false;
        _errorMessage = '当前环境暂时无法回放这段录音。';
      });
    }
  }

  Future<void> _clearLearnerRecording() async {
    if (_isPlayingLearnerRecording) {
      await _practiceService.stopLearnerRecordingPlayback();
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _isPlayingLearnerRecording = false;
      _learnerRecording = null;
      _statusMessage = '已清空本轮录音，你可以重新录一遍。';
    });
  }

  Future<void> _toggleRecognition() async {
    if (_referenceText.isEmpty) {
      return;
    }
    if (_isRecordingLearnerVoice) {
      return;
    }

    if (_isListening) {
      await _finalizeRecognitionAfterManualStop();
      return;
    }

    if (_isSpeaking) {
      await _practiceService.stopSpeaking();
    }
    if (_isPlayingLearnerRecording) {
      await _practiceService.stopLearnerRecordingPlayback();
    }

    _didFinalizeCurrentSession = false;
    setState(() {
      _isSpeaking = false;
      _isPlayingLearnerRecording = false;
      _transcript = '';
      _checkResult = null;
      _errorMessage = null;
      _statusMessage = '正在启动语音识别，请直接跟读。';
    });

    final started = await _practiceService.startListening(
      accentPreference: _accentPreference,
      onResult: _handleRecognitionResult,
      onError: _handleRecognitionError,
      onStatus: _handleRecognitionStatus,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isListening = started;
      if (!started && _errorMessage == null) {
        _errorMessage = '当前浏览器没有成功启动语音识别。';
        _statusMessage = null;
      }
    });
  }

  Future<void> _finalizeRecognitionAfterManualStop() async {
    final transcript = await _practiceService.stopListening();
    _finalizeRecognitionSession(
      transcriptOverride: transcript,
      statusMessage:
          transcript.isEmpty ? '已停止识别，但没有抓到有效英文。' : '识别已停止，已生成自动检查。',
    );
  }

  void _handleRecognitionResult(SpeechRecognitionResult result) {
    if (!mounted) {
      return;
    }

    setState(() {
      _transcript = result.recognizedWords.trim();
    });

    if (result.finalResult) {
      _finalizeRecognitionSession(
        statusMessage:
            _transcript.isEmpty ? '识别结束，但还没有拿到有效英文。' : '识别结束，已生成自动检查。',
      );
    }
  }

  void _handleRecognitionError(String message) {
    if (!mounted) {
      return;
    }

    _didFinalizeCurrentSession = true;
    setState(() {
      _errorMessage = _friendlyRecognitionError(message);
      _statusMessage = null;
      _isListening = false;
    });
  }

  void _handleRecognitionStatus(String status) {
    if (!mounted) {
      return;
    }

    final normalized = status.toLowerCase();
    if (normalized.contains('notlistening') || normalized.contains('done')) {
      _finalizeRecognitionSession(
        statusMessage:
            _transcript.isEmpty ? '识别结束，但还没有拿到有效英文。' : '识别结束，已生成自动检查。',
      );
    }
  }

  void _finalizeRecognitionSession({
    String? transcriptOverride,
    String? statusMessage,
  }) {
    if (_didFinalizeCurrentSession) {
      return;
    }
    _didFinalizeCurrentSession = true;

    final resolvedTranscript = transcriptOverride?.trim().isNotEmpty == true
        ? transcriptOverride!.trim()
        : _transcript.trim();
    final result = PronunciationCheckEngine.analyze(
      step: widget.step,
      referenceText: widget.step == null ? _referenceText : null,
      focusWords: widget.step == null ? _focusWords : null,
      transcript: resolvedTranscript,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _transcript = resolvedTranscript;
      _checkResult = result;
      _isListening = false;
      _statusMessage = statusMessage;
    });

    if (result.hasTranscript) {
      widget.onCheckCompleted?.call(result);
    }
  }

  void _resetCheck() {
    _didFinalizeCurrentSession = false;
    setState(() {
      _transcript = '';
      _checkResult = null;
      _errorMessage = null;
      _statusMessage = null;
    });
  }

  String _friendlyRecognitionError(String message) {
    final normalized = message.toLowerCase();
    if (normalized.contains('permission') ||
        normalized.contains('not-allowed')) {
      return '浏览器没有授权麦克风，请先允许录音权限。';
    }
    if (normalized.contains('audio-capture') ||
        normalized.contains('microphone')) {
      return '没有检测到可用麦克风，请检查设备输入。';
    }
    if (normalized.contains('network')) {
      return '语音识别依赖浏览器联网能力，请检查网络后重试。';
    }
    return '语音识别启动失败：$message';
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final String text;

  const _InfoBox({
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 18, color: textColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: textColor, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _LearnerRecordingCard extends StatelessWidget {
  final String panelId;
  final LearnerRecording recording;
  final bool isPlaying;
  final VoidCallback onTogglePlayback;
  final VoidCallback onClear;

  const _LearnerRecordingCard({
    required this.panelId,
    required this.recording,
    required this.isPlaying,
    required this.onTogglePlayback,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('speech-recording-$panelId'),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '我的跟读录音',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            '真实录音时长：${recording.durationLabel}。当前仅保存在本轮练习会话中，可随时回放对照。',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: onTogglePlayback,
                icon: Icon(
                  isPlaying
                      ? Icons.stop_circle_outlined
                      : Icons.play_circle_fill_rounded,
                ),
                label: Text(isPlaying ? '停止回放' : '回放我的录音'),
              ),
              OutlinedButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('删除这段录音'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AutomaticCheckCard extends StatelessWidget {
  final PronunciationCheckResult result;
  final Color accentColor;
  final String panelId;

  const _AutomaticCheckCard({
    required this.result,
    required this.accentColor,
    required this.panelId,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (result.level) {
      PronunciationCheckLevel.retry => AppColors.errorRed,
      PronunciationCheckLevel.partial => AppColors.accentOrange,
      PronunciationCheckLevel.good => AppColors.successGreen,
    };

    return Container(
      key: ValueKey('speech-check-$panelId'),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '自动检查（识别版）',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  result.levelLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const SizedBox(
                width: 76,
                child: Text(
                  '识别覆盖',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: result.recognitionCoverage,
                    minHeight: 8,
                    backgroundColor: statusColor.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(statusColor),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${result.recognitionCoveragePercent}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ],
          ),
          if (result.matchedFocusWords.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              '已识别重点词：${result.matchedFocusWords.join(' / ')}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ],
          if (result.missingFocusWords.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '待补强重点词：${result.missingFocusWords.join(' / ')}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.accentOrange,
              ),
            ),
          ],
          if (result.missingWords.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '仍未稳定识别：${result.missingWords.join(' / ')}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 14),
          ...result.notes.map(
            (note) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.arrow_right_alt,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      note,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.55,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
