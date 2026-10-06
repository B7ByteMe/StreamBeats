import 'dart:async';
import 'dart:developer';

import 'package:streambeats/services/db/dao/cache_dao.dart';

class PluginCacheWriter {
  final CacheDAO _cacheDao;

  final _pending = <String, _WriteEntry>{};
  Timer? _flushTimer;

  static const _flushDelay = Duration(seconds: 2);
  static const _maxPending = 10;

  PluginCacheWriter(this._cacheDao);

  void schedule(String key, String blob, {Duration? ttl}) {
    _pending[key] = _WriteEntry(blob, ttl);

    if (_pending.length >= _maxPending) {
      _flushTimer?.cancel();
      unawaited(_flush());
      return;
    }

    _flushTimer?.cancel();
    _flushTimer = Timer(_flushDelay, () => unawaited(_flush()));
  }

  Future<void> flushNow() async {
    _flushTimer?.cancel();
    await _flush();
  }

  void dispose() {
    _flushTimer?.cancel();
  }

  Future<void> _flush() async {
    if (_pending.isEmpty) return;

    final batch = Map<String, _WriteEntry>.from(_pending);
    _pending.clear();

    try {
      await _cacheDao.putCacheBatch({
        for (final e in batch.entries)
          e.key: (value: e.value.blob, ttl: e.value.ttl),
      });
    } catch (e, st) {
      log('PluginCacheWriter flush failed: $e',
          stackTrace: st, name: 'PluginCacheWriter');
    }
  }
}

class _WriteEntry {
  final String blob;
  final Duration? ttl;
  const _WriteEntry(this.blob, this.ttl);
}