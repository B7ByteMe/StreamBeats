import 'dart:collection';

enum CacheType { chart, sections, chartList }

class _LruEntry {
  final Object value;
  final DateTime storedAt;
  _LruEntry(this.value, this.storedAt);
}

class _LruMap {
  final int capacity;
  final _map = LinkedHashMap<String, _LruEntry>();

  _LruMap(this.capacity);

  _LruEntry? get(String key) {
    final val = _map.remove(key);
    if (val != null) _map[key] = val; // move to MRU end
    return val;
  }

  void put(String key, _LruEntry entry) {
    _map.remove(key);
    _map[key] = entry;
    while (_map.length > capacity) {
      _map.remove(_map.keys.first); // evict LRU
    }
  }

  void removeWhere(bool Function(String key) test) =>
      _map.removeWhere((k, _) => test(k));

  void clear() => _map.clear();

  void trimTo(int size) {
    while (_map.length > size) {
      _map.remove(_map.keys.first);
    }
  }
}

class PluginCacheStore {
  final _charts = _LruMap(8); // chart item lists per chartId
  final _sections = _LruMap(5); // home sections per pluginId
  final _chartLists = _LruMap(5); // chart summaries per pluginId

  ({T value, DateTime storedAt})? getWithAge<T>(String key, CacheType type) {
    final entry = _poolFor(type).get(key);
    if (entry == null) return null;
    final v = entry.value;
    if (v is! T) return null;
    return (value: v as T, storedAt: entry.storedAt);
  }

  void put(String key, Object value, CacheType type, {DateTime? storedAt}) {
    _poolFor(type).put(key, _LruEntry(value, storedAt ?? DateTime.now()));
  }

  void evictPrefix(String prefix) {
    for (final pool in [_charts, _sections, _chartLists]) {
      pool.removeWhere((k) => k.startsWith(prefix));
    }
  }

  void clearAll() {
    _charts.clear();
    _sections.clear();
    _chartLists.clear();
  }

  void trimToHalf() {
    _charts.trimTo(4);
    _sections.trimTo(2);
    _chartLists.trimTo(2);
  }

  _LruMap _poolFor(CacheType type) => switch (type) {
        CacheType.chart => _charts,
        CacheType.sections => _sections,
        CacheType.chartList => _chartLists,
      };
}