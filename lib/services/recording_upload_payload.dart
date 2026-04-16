import 'dart:typed_data';

import 'recording_upload_payload_stub.dart'
    if (dart.library.html) 'recording_upload_payload_web.dart'
    if (dart.library.io) 'recording_upload_payload_io.dart'
    as loader;

class RecordingUploadPayload {
  final Uint8List bytes;
  final String mimeType;
  final String filename;

  const RecordingUploadPayload({
    required this.bytes,
    required this.mimeType,
    required this.filename,
  });
}

Future<RecordingUploadPayload?> loadRecordingUploadPayload(String path) {
  return loader.loadRecordingUploadPayload(path);
}
