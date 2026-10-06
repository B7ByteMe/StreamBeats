import 'package:streambeats/core/models/lyrics_models.dart';
import 'package:streambeats/services/db/global_db.dart';
import 'package:streambeats/services/db/mappers/lyrics_mapper.dart';
import 'package:isar_community/isar.dart';

class LyricsDAO {
  final Future<Isar> _db;

  const LyricsDAO(this._db);

  Future<void> putLyrics(Lyrics lyrics, {int? offset}) async {
    if (lyrics.mediaID == null || lyrics.mediaID!.isEmpty) return;
    final isar = await _db;
    await isar.writeTxn(
        () => isar.lyricsDBs.put(lyricsToLyricsDB(lyrics, offset: offset)));
  }

  Future<Lyrics?> getLyrics(String mediaID) async {
    final isar = await _db;
    final row =
        await isar.lyricsDBs.filter().mediaIDEqualTo(mediaID).findFirst();
    return lyricsDBToLyrics(row);
  }

  Future<void> removeLyricsById(String mediaID) async {
    final isar = await _db;
    await isar.writeTxn(
        () => isar.lyricsDBs.filter().mediaIDEqualTo(mediaID).deleteAll());
  }

  Future<void> clearAll() async {
    final isar = await _db;
    await isar.writeTxn(() => isar.lyricsDBs.clear());
  }

  Future<void> updateMediaId(String oldMediaId, String newMediaId) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      final existing =
          await isar.lyricsDBs.filter().mediaIDEqualTo(oldMediaId).findFirst();
      if (existing != null) {
        existing.mediaID = newMediaId;
        await isar.lyricsDBs.put(existing);
      }
    });
  }
}