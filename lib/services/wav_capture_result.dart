import 'dart:typed_data';

class WavCaptureResult {
  final Uint8List bytes;
  final Duration duration;
  final String objectUrl;

  const WavCaptureResult({
    required this.bytes,
    required this.duration,
    required this.objectUrl,
  });
}
