import 'dart:developer';

import 'package:streambeats/services/db/dao/track_dao.dart';
import 'package:streambeats/services/db/global_db.dart';
import 'package:streambeats/services/db/mappers/media_item_mapper.dart';
import 'package:streambeats/src/rust/api/plugin/models.dart';
import 'package:isar_community/isar.dart';

class HistoryDAO {
  final Future<Isar> _db;
  final TrackDAO _trackDAO;

  const HistoryDAO(this._db, this._trackDAO);

  Future<void> recordPlay(Track track) async {
    final isar = await _db;
    final trackId = await _trackDAO.upsertTrack(track);
    final trackObj = await isar.trackDBs.get(trackId);
    if (trackObj == null) {
      log('recordPlay: track ${track.id} not found after upsert',
          name: 'HistoryDAO');
      return;
    }

    final entry = PlaybackHistoryDB(playedAt: DateTime.now())
      ..track.value = trackObj;

    await isar.writeTxn(() async {
      await isar.playbackHistoryDBs.put(entry);
      await entry.track.save();
    });
    log('Recorded play for ${track.id}', name: 'HistoryDAO');
  }

  Future<List<Track>> getHistory({int limit = 50}) async {
    final isar = await _db;
    final query = isar.playbackHistoryDBs.where().sortByPlayedAtDesc();

    final entries =
        limit > 0 ? await query.limit(limit).findAll() : await query.findAll();

    await Future.wait(entries.map((e) => e.track.load()));

    final seen = <String>{};
    return entries
    .map((e) => e.track.value)
    .whereType<TrackDB>()
    .where((t) => seen.add(t.mediaId))
    .map(trackDBToTrack)
    .toList();
  }

  Future<List<PlaybackHistoryDB>> getRawHistory({int limit = 50}) async {
    final isar = await _db;
    final query = isar.playbackHistoryDBs.where().sortByPlayedAtDesc();
    final entries =
        limit > 0 ? await query.limit(limit).findAll() : await query.findAll();
    await Future.wait(entries.map((e) => e.track.load()));
    return entries;
  }

  Future<int> purgeBrokenHistoryEntries() async {
    final isar = await _db;
    final entries = await isar.playbackHistoryDBs.where().findAll();
    await Future.wait(entries.map((e) => e.track.load()));

    final brokenIds = entries
        .where((e) => e.track.value == null)
        .map((e) => e.id)
        .toList(growable: false);

    if (brokenIds.isEmpty) return 0;

    final deleted = await isar.writeTxn(() async {
      return isar.playbackHistoryDBs.deleteAll(brokenIds);
    });

    log('Purged $deleted broken history entries', name: 'HistoryDAO');
    return deleted;
  }

  Future<int> purgeOldHistory(int days) async {
    if (days <= 0) return 0;
    final isar = await _db;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final count = await isar.writeTxn(() =>
        isar.playbackHistoryDBs.filter().playedAtLessThan(cutoff).deleteAll());
    log('Purged $count history entries older than $days days',
        name: 'HistoryDAO');
    return count;
  }

  Future<void> removeHistoryEntry(int id) async {
    final isar = await _db;
    await isar.writeTxn(() => isar.playbackHistoryDBs.delete(id));
  }

  Future<void> clearHistory() async {
    final isar = await _db;
    await isar.writeTxn(() => isar.playbackHistoryDBs.clear());
    log('Cleared all history', name: 'HistoryDAO');
  }

  Future<Stream<void>> watchHistory() async {
    final isar = await _db;
    return isar.playbackHistoryDBs.watchLazy(fireImmediately: true);
  }
}