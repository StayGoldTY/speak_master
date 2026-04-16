import 'dart:io';

import 'recording_upload_payload.dart';

Future<RecordingUploadPayload?> loadRecordingUploadPayload(String path) async {
  if (path.trim().isEmpty) {
    return null;
  }

  final file = File(path);
  if (!await file.exists()) {
    return null;
  }

  return RecordingUploadPayload(
    bytes: await file.readAsBytes(),
    mimeType: _mimeTypeForPath(path),
    filename: path.split(RegExp(r'[\\/]')).last,
  );
}

String _mimeTypeForPath(String path) {
  final normalized = path.toLowerCase();
  if (normalized.endsWith('.mp3')) {
    return 'audio/mpeg';
  }
  if (normalized.endsWith('.m4a') || normalized.endsWith('.aac')) {
    return 'audio/mp4';
  }
  if (normalized.endsWith('.wav')) {
    return 'audio/wav';
  }
  if (normalized.endsWith('.ogg') || normalized.endsWith('.opus')) {
    return 'audio/ogg';
  }
  if (normalized.endsWith('.flac')) {
    return 'audio/flac';
  }
  if (normalized.endsWith('.webm')) {
    return 'audio/webm';
  }
  return 'application/octet-stream';
}
