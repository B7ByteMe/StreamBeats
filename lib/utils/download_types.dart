import 'package:streambeats/core/models/exported.dart';

enum DownloadState {
  queued,
  resolving,
  downloading,
  paused,
  retrying,
  fetchingMetadata,
  completed,
  failed,
  cancelled,
}

class DownloadStatus {
  final DownloadState state;
  final double progress;
  final String? message;
  final String? filePath;

  const DownloadStatus({
    required this.state,
    this.progress = 0.0,
    this.message,
    this.filePath,
  });
}

class DownloadTask {
  final String taskId;

  final Track song;

  final String mediaId;

  final String fileName;

  final String targetPath;

  const DownloadTask({
    required this.taskId,
    required this.song,
    required this.mediaId,
    this.fileName = '',
    this.targetPath = '',
  });
}