import 'dart:developer';
import 'package:isar_community/isar.dart';
import 'package:streambeats/services/db/global_db.dart';

class PluginStorageDao {
  final Future<Isar> _db;

  PluginStorageDao(this._db);

  Future<void> putEntry({
    required String pluginId,
    required String key,
    required String value,
  }) async {
    final isar = await _db;
    final entity = PluginStorageEntity(
      pluginId: pluginId,
      key: key,
      value: value,
      updatedAt: DateTime.now(),
    );
    await isar.writeTxn(() async {
      await isar.pluginStorageEntitys.put(entity);
    });
  }

  Future<PluginStorageEntity?> getEntry({
    required String pluginId,
    required String key,
  }) async {
    final isar = await _db;
    final compositeKey = '$pluginId/$key';
    return isar.pluginStorageEntitys
        .where()
        .compositeKeyEqualTo(compositeKey)
        .findFirst();
  }

  Future<List<PluginStorageEntity>> getAllForPlugin(String pluginId) async {
    final isar = await _db;
    return isar.pluginStorageEntitys
        .where()
        .pluginIdEqualTo(pluginId)
        .findAll();
  }

  Future<List<PluginStorageEntity>> getAll() async {
    final isar = await _db;
    return isar.pluginStorageEntitys.where().findAll();
  }

  Future<void> deleteEntry({
    required String pluginId,
    required String key,
  }) async {
    final isar = await _db;
    final compositeKey = '$pluginId/$key';
    await isar.writeTxn(() async {
      await isar.pluginStorageEntitys
          .where()
          .compositeKeyEqualTo(compositeKey)
          .deleteAll();
    });
  }

  Future<void> clearPlugin(String pluginId) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.pluginStorageEntitys
          .where()
          .pluginIdEqualTo(pluginId)
          .deleteAll();
    });
    log('Cleared storage for plugin: $pluginId', name: 'PluginStorageDao');
  }

  Future<void> clearAll() async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.pluginStorageEntitys.clear();
    });
  }
}