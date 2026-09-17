import 'wav_capture_result.dart';

class WebWavRecorder {
  bool get isAvailable => false;

  Future<bool> start() async => false;

  Future<WavCaptureResult?> stop() async => null;

  Future<void> cancel() async {}
}
