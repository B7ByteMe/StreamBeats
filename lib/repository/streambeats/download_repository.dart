import 'package:streambeats/core/models/exported.dart';
import 'package:streambeats/services/db/global_db.dart';
import 'package:streambeats/services/db/dao/download_dao.dart';

class DownloadRepository {
  final DownloadDAO _downloadDao;

  const DownloadRepository(this._downloadDao);

  Future<void> saveDownload({
    required String fileName,
    required String filePath,
    required DateTime lastDownloaded,
    required Track track,
  }) =>
      _downloadDao.putDownload(
        fileName: fileName,
        filePath: filePath,
        track: track,
        lastDownloaded: lastDownloaded,
      );

  Future<void> removeDownload(String mediaId) =>
      _downloadDao.removeDownload(mediaId);

  Future<DownloadDB?> getDownload(String mediaId) =>
      _downloadDao.getDownloadRecord(mediaId);

  Future<void> updateDownload(DownloadDB downloadDB) =>
      _downloadDao.updateDownloadRecord(downloadDB);

  Future<List<DownloadDB>> getDownloadedSongs() =>
      _downloadDao.getValidDownloads();

  Future<List<Track>> getDownloadedTracks() =>
      _downloadDao.getValidDownloadedTracks();

  Future<bool> isDownloaded(String mediaId) =>
      _downloadDao.isDownloaded(mediaId);
}