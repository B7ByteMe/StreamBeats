import 'dart:developer';

import 'package:streambeats/services/db/global_db.dart';
import 'package:isar_community/isar.dart';

class CacheDAO {
  final Future<Isar> _db;

  const CacheDAO(this._db);

  Future<void> putCache(
    String key,
    String value, {
    String? blob,
    Duration? ttl,
  }) async {
    if (key.isEmpty) return;
    final isar = await _db;
    final expiry = ttl != null ? DateTime.now().add(ttl) : null;
    final entry = CacheEntryDB(
      key: key,
      value: value,
      blob: blob,
      lastUpdated: DateTime.now(),
      ttl: expiry,
    );
    await isar.writeTxn(() => isar.cacheEntryDBs.put(entry));
  }

  Future<CacheEntryDB?> getCache(String key) async {
    final isar = await _db;
    final entry = await isar.cacheEntryDBs.filter().keyEqualTo(key).findFirst();
    if (entry == null) return null;

    if (entry.isExpired) {
      await isar.writeTxn(() => isar.cacheEntryDBs.delete(entry.id));
      log('Cache miss (expired): $key', name: 'CacheDAO');
      return null;
    }
    return entry;
  }

  Future<String?> getCacheValue(String key) async {
    final entry = await getCache(key);
    return entry?.value;
  }

  Future<void> removeCache(String key) async {
    final isar = await _db;
    await isar.writeTxn(
        () => isar.cacheEntryDBs.filter().keyEqualTo(key).deleteAll());
  }

  Future<int> purgeExpiredCache() async {
    final isar = await _db;
    final now = DateTime.now();
    final count = await isar.writeTxn(() => isar.cacheEntryDBs
        .filter()
        .ttlIsNotNull()
        .ttlLessThan(now)
        .deleteAll());
    if (count > 0) {
      log('Purged $count expired cache entries', name: 'CacheDAO');
    }
    return count;
  }

  Future<void> clearAllCache() async {
    final isar = await _db;
    await isar.writeTxn(() => isar.cacheEntryDBs.clear());
    log('Cleared all cache', name: 'CacheDAO');
  }

  Future<void> putCacheBatch(
    Map<String, ({String value, Duration? ttl})> entries,
  ) async {
    if (entries.isEmpty) return;
    final isar = await _db;
    final now = DateTime.now();
    final objects = entries.entries
        .map((e) => CacheEntryDB(
              key: e.key,
              value: e.value.value,
              lastUpdated: now,
              ttl: e.value.ttl != null ? now.add(e.value.ttl!) : null,
            ))
        .toList();
    await isar.writeTxn(() => isar.cacheEntryDBs.putAll(objects));
  }

  Future<void> putApiToken(
    String apiName,
    String token, {
    int expireInSeconds = 0,
  }) async {
    final isar = await _db;
    await isar.writeTxn(() => isar.appSettingsStrDBs.put(
          AppSettingsStrDB(
            settingName: apiName,
            settingValue: token,
            settingValue2: expireInSeconds.toString(),
            lastUpdated: DateTime.now(),
          ),
        ));
  }

  Future<String?> getApiToken(String apiName) async {
    final isar = await _db;
    final record = await isar.appSettingsStrDBs
        .filter()
        .settingNameEqualTo(apiName)
        .findFirst();
    if (record == null) return null;

    final expireIn = int.tryParse(record.settingValue2 ?? '0') ?? 0;
    if (expireIn == 0) return record.settingValue; // never expires

    final age = DateTime.now()
        .difference(
            record.lastUpdated ?? DateTime.fromMillisecondsSinceEpoch(0))
        .inSeconds
        .abs();
    if (age < expireIn - 30) return record.settingValue; // 30-s safety margin
    return null; // expired
  }

  Future<void> removeApiToken(String apiName) async {
    final isar = await _db;
    await isar.writeTxn(() => isar.appSettingsStrDBs
        .filter()
        .settingNameEqualTo(apiName)
        .deleteAll());
  }
}