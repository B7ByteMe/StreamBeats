part of 'downloader_cubit.dart';

class DownloadProgress with EquatableMixin {
  final DownloadTask task;
  final DownloadStatus status;

  DownloadProgress({required this.task, required this.status});

  @override
  List<Object?> get props => [
        task.taskId.isEmpty ? task.mediaId : task.taskId,
        status.state,
        status.progress,
      ];
}

abstract class DownloaderState extends Equatable {
  final List<DownloadProgress> downloads;
  final List<Track> downloaded;

  const DownloaderState(
      {this.downloads = const [], this.downloaded = const []});

  @override
  List<Object> get props => [downloads, downloaded, runtimeType];
}

class DownloaderInitial extends DownloaderState {}

class DownloaderLoaded extends DownloaderState {
  const DownloaderLoaded({
    required List<DownloadProgress> downloads,
    required List<Track> downloaded,
  }) : super(downloads: downloads, downloaded: downloaded);
}

class DownloaderTasksUpdated extends DownloaderState {
  const DownloaderTasksUpdated(
      List<DownloadProgress> downloads, List<Track> downloaded)
      : super(downloads: downloads, downloaded: downloaded);
}