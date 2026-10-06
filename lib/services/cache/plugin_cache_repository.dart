import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:streambeats/services/cache/plugin_cache_store.dart';
import 'package:streambeats/services/cache/plugin_cache_writer.dart';
import 'package:streambeats/services/db/dao/cache_dao.dart';
import 'package:streambeats/services/db/global_db.dart' show CacheEntryDB;

export 'package:streambeats/services/cache/plugin_cache_store.dart' show CacheType;

class PluginCacheRepository with WidgetsBindingObserver {
  final PluginCacheStore _store;
  final CacheDAO _cacheDao;
  final PluginCacheWriter _writer;

  final _inFlight = <String, Future<dynamic>>{};

  PluginCacheRepository({
    required PluginCacheStore store,
    required CacheDAO cacheDao,
    required PluginCacheWriter writer,
  })  : _store = store,
        _cacheDao = cacheDao,
        _writer = writer {
    WidgetsBinding.instance.addObserver(this);
  }

  Future<({T? value, bool isStale})> getCachedWithStaleness<T>({
    required String key,
    required CacheType type,
    required Future<T> Function(String blob) decode,
    required Duration stalenessThreshold,
  }) async {
    final l1 = _store.getWithAge<T>(key, type);
    if (l1 != null) {
      final stale =
          l1.storedAt.add(stalenessThreshold).isBefore(DateTime.now());
      return (value: l1.value, isStale: stale);
    }

    CacheEntryDB? entry;
    try {
      entry = await _cacheDao.getCache(key);
    } catch (e) {
      log('L2 read failed for $key: $e', name: 'PluginCacheRepository');
    }
    if (entry == null || entry.value.isEmpty)
      return (value: null, isStale: true);

    final T decoded = await decode(entry.value);

    _store.put(key, decoded as Object, type,
        storedAt: entry.lastUpdated ?? DateTime.now());

    final storedAt =
        entry.lastUpdated ?? DateTime.fromMillisecondsSinceEpoch(0);
    final stale = storedAt.add(stalenessThreshold).isBefore(DateTime.now());
    return (value: decoded, isStale: stale);
  }

  void put({
    required String key,
    required Object value,
    required CacheType type,
    required String blob,
    Duration? ttl,
  }) {
    _store.put(key, value, type);
    _writer.schedule(key, blob, ttl: ttl);
  }

  Future<T> deduplicate<T>(String key, Future<T> Function() work) {
    if (_inFlight.containsKey(key)) {
      return _inFlight[key]! as Future<T>;
    }
    final future = work().whenComplete(() => _inFlight.remove(key));
    _inFlight[key] = future;
    return future;
  }

  void evictPlugin(String pluginId) {
    _store.evictPrefix('chart_cache::$pluginId::');
    _store.evictPrefix('home_sections::$pluginId');
    _store.evictPrefix('chart_list::$pluginId');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _store.trimToHalf();
      unawaited(_writer.flushNow());
    }
  }

  @override
  void didHaveMemoryPressure() {
    _store.clearAll();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _writer.dispose();
  }
}