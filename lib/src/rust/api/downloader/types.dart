import '../../frb_generated.dart';
import '../plugin/models.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:freezed_annotation/freezed_annotation.dart' hide protected;
part 'types.freezed.dart';

@freezed
sealed class DownloadManagerEvent with _$DownloadManagerEvent {
  const DownloadManagerEvent._();

  const factory DownloadManagerEvent.taskUpdated(
    DownloadTaskSnapshot field0,
  ) = DownloadManagerEvent_TaskUpdated;

  const factory DownloadManagerEvent.taskCompletedPendingAck(
    DownloadTaskSnapshot field0,
  ) = DownloadManagerEvent_TaskCompletedPendingAck;

  const factory DownloadManagerEvent.taskRemoved({
    required String taskId,
  }) = DownloadManagerEvent_TaskRemoved;

  const factory DownloadManagerEvent.recoverySummary({
    required int restored,
    required int cleaned,
  }) = DownloadManagerEvent_RecoverySummary;
}

class DownloadTaskSnapshot {
  final String taskId;
  final Track track;
  final String fileName;
  final String targetPath;
  final String tempPath;
  final DownloadTaskState state;
  final double progress;
  final BigInt bytesDownloaded;
  final BigInt? totalBytes;
  final String? message;
  final String? lastError;

  const DownloadTaskSnapshot({
    required this.taskId,
    required this.track,
    required this.fileName,
    required this.targetPath,
    required this.tempPath,
    required this.state,
    required this.progress,
    required this.bytesDownloaded,
    this.totalBytes,
    this.message,
    this.lastError,
  });

  @override
  int get hashCode =>
      taskId.hashCode ^
      track.hashCode ^
      fileName.hashCode ^
      targetPath.hashCode ^
      tempPath.hashCode ^
      state.hashCode ^
      progress.hashCode ^
      bytesDownloaded.hashCode ^
      totalBytes.hashCode ^
      message.hashCode ^
      lastError.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadTaskSnapshot &&
          runtimeType == other.runtimeType &&
          taskId == other.taskId &&
          track == other.track &&
          fileName == other.fileName &&
          targetPath == other.targetPath &&
          tempPath == other.tempPath &&
          state == other.state &&
          progress == other.progress &&
          bytesDownloaded == other.bytesDownloaded &&
          totalBytes == other.totalBytes &&
          message == other.message &&
          lastError == other.lastError;
}

enum DownloadTaskState {
  queued,
  resolving,
  downloading,
  paused,
  retrying,
  writingMetadata,

  completedPendingAck,
  failed,
  cancelled,
  ;
}

class EnqueueDownloadRequest {
  final Track track;
  final String downloadDir;
  final String preferredQuality;

  const EnqueueDownloadRequest({
    required this.track,
    required this.downloadDir,
    required this.preferredQuality,
  });

  @override
  int get hashCode =>
      track.hashCode ^ downloadDir.hashCode ^ preferredQuality.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnqueueDownloadRequest &&
          runtimeType == other.runtimeType &&
          track == other.track &&
          downloadDir == other.downloadDir &&
          preferredQuality == other.preferredQuality;
}