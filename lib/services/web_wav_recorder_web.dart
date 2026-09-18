import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'wav_capture_result.dart';

@JS('SpeakMasterWavRecorder')
external SpeakMasterWavRecorderJs? get _nativeRecorder;

@JS()
@staticInterop
class SpeakMasterWavRecorderJs {}

extension SpeakMasterWavRecorderJsExt on SpeakMasterWavRecorderJs {
  @JS('start')
  external JSPromise<JSAny?> start();

  @JS('stop')
  external JSPromise<JSAny?> stop();

  @JS('cancel')
  external JSPromise<JSAny?> cancel();
}

class WebWavRecorder {
  bool get isAvailable => _nativeRecorder != null;

  Future<bool> start() async {
    final recorder = _nativeRecorder;
    if (recorder == null) {
      return false;
    }

    try {
      await recorder.start().toDart;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<WavCaptureResult?> stop() async {
    final recorder = _nativeRecorder;
    if (recorder == null) {
      return null;
    }

    try {
      final raw = await recorder.stop().toDart;
      if (raw == null) {
        return null;
      }

      final decoded = raw.dartify();
      if (decoded is! Map) {
        return null;
      }

      final encoded = decoded['wavBase64']?.toString() ?? '';
      if (encoded.isEmpty) {
        return null;
      }

      final bytes = Uint8List.fromList(base64Decode(encoded));
      final durationMs = (decoded['durationMs'] as num?)?.toInt() ?? 0;

      return WavCaptureResult(
        bytes: bytes,
        duration: Duration(milliseconds: durationMs),
        objectUrl: 'data:audio/wav;base64,$encoded',
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> cancel() async {
    final recorder = _nativeRecorder;
    if (recorder == null) {
      return;
    }

    try {
      await recorder.cancel().toDart;
    } catch (_) {}
  }
}
