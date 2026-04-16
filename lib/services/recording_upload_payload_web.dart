import 'package:http/http.dart' as http;

import 'recording_upload_payload.dart';

Future<RecordingUploadPayload?> loadRecordingUploadPayload(String path) async {
  if (path.trim().isEmpty) {
    return null;
  }

  final response = await http.get(Uri.parse(path));
  if (response.statusCode >= 400 || response.bodyBytes.isEmpty) {
    return null;
  }

  final mimeType = response.headers['content-type'] ?? 'audio/webm';

  return RecordingUploadPayload(
    bytes: response.bodyBytes,
    mimeType: mimeType,
    filename: _filenameForMimeType(mimeType),
  );
}

String _filenameForMimeType(String mimeType) {
  if (mimeType.contains('mpeg')) {
    return 'attempt.mp3';
  }
  if (mimeType.contains('mp4') || mimeType.contains('aac')) {
    return 'attempt.m4a';
  }
  if (mimeType.contains('wav')) {
    return 'attempt.wav';
  }
  if (mimeType.contains('ogg') || mimeType.contains('opus')) {
    return 'attempt.ogg';
  }
  if (mimeType.contains('flac')) {
    return 'attempt.flac';
  }
  return 'attempt.webm';
}
