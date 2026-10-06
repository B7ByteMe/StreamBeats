import '../frb_generated.dart';
import 'downloader/types.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'plugin/models.dart';
import 'plugin/plugin.dart';

abstract class DownloadManager implements RustOpaqueInterface {
  Future<bool> acknowledgePersisted({required String taskId});

  Future<bool> cancelTask(
      {required String taskId, required bool deletePartial});

  Future<String> enqueue({required EnqueueDownloadRequest request});

  Future<List<DownloadTaskSnapshot>> getSnapshots();

  Stream<DownloadManagerEvent> initEventStream();

  static Future<DownloadManager> newInstance(
          {required PluginManager pluginManager,
          required String stateDir,
          required String tempDir,
          required int maxConcurrentTasks}) =>
      RustLib.instance.api.crateApiDownloaderDownloadManagerNew(
          pluginManager: pluginManager,
          stateDir: stateDir,
          tempDir: tempDir,
          maxConcurrentTasks: maxConcurrentTasks);

  Future<bool> pauseTask({required String taskId});

  Future<List<DownloadTaskSnapshot>> restoreTasks();

  Future<bool> resumeTask({required String taskId});
}