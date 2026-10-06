library;

import 'dart:developer';
import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;

import 'legacy_global_db.dart';

const legacyDbName = 'default';

const List<CollectionSchema<dynamic>> _legacySchemas = [
  MediaPlaylistDBSchema,
  MediaItemDBSchema,
  AppSettingsBoolDBSchema,
  AppSettingsStrDBSchema,
  DownloadDBSchema,
  SavedCollectionsDBSchema,
  PlaylistsInfoDBSchema,
];

Isar? _legacyInstance;
Directory? _stagingDir;

bool legacyDbExists(String dir) =>
    File(p.join(dir, 'default.isar')).existsSync() ||
    File(p.join(dir, 'default.isar.db')).existsSync() ||
    File(p.join(dir, 'default.db')).existsSync();

Future<Isar> openLegacyDB(
  String dir, {
  String? legacyFilePath,
  String? appSuppDir,
}) async {
  if (_legacyInstance != null && _legacyInstance!.isOpen) {
    return _legacyInstance!;
  }

  final named = Isar.getInstance(legacyDbName);
  if (named != null && named.isOpen) {
    _legacyInstance = named;
    return named;
  }

  var openDir = dir;

  if (legacyFilePath != null) {
    final source = File(legacyFilePath);
    final sourceName = p.basename(source.path).toLowerCase();

    if (sourceName != 'default.isar') {
      final stagingRoot = Directory(
        p.join(appSuppDir ?? dir, 'legacy_migration_staging'),
      );
      if (!stagingRoot.existsSync()) {
        stagingRoot.createSync(recursive: true);
      }

      final stagedDir = Directory(
        p.join(
            stagingRoot.path, DateTime.now().millisecondsSinceEpoch.toString()),
      );
      stagedDir.createSync(recursive: true);

      final stagedFile = File(p.join(stagedDir.path, 'default.isar'));
      source.copySync(stagedFile.path);
      openDir = stagedDir.path;
      _stagingDir = stagedDir;

      log(
        'Staged legacy DB ${source.path} to ${stagedFile.path} for migration open',
        name: 'LegacyDBOpener',
      );
    }
  }

  log('Opening legacy DB at $openDir/default.isar', name: 'LegacyDBOpener');
  _legacyInstance = Isar.openSync(
    _legacySchemas,
    directory: openDir,
    name: legacyDbName,
    relaxedDurability: true, // read-heavy; we never write
  );
  return _legacyInstance!;
}

Future<void> closeLegacyDB() async {
  try {
    if (_legacyInstance != null && _legacyInstance!.isOpen) {
      await _legacyInstance!.close();
      _legacyInstance = null;
      log('Legacy DB closed', name: 'LegacyDBOpener');
    }

    if (_stagingDir != null && _stagingDir!.existsSync()) {
      _stagingDir!.deleteSync(recursive: true);
      log('Legacy DB staging cleaned', name: 'LegacyDBOpener');
    }
    _stagingDir = null;
  } catch (e) {
    log('Error closing legacy DB', error: e, name: 'LegacyDBOpener');
  }
}