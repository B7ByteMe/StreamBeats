import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:streambeats/core/constants/setting_keys.dart';
import 'package:streambeats/services/db/db_provider.dart';
import 'package:streambeats/services/db/dao/settings_dao.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

bool isUpdateAvailable(
    String currentVer, String currentBuild, String newVer, String newBuild,
    {bool checkBuild = true}) {
  List<int> parseVersion(String v) {
    v = v.replaceFirst(RegExp(r'^v'), '');
    final parts = v.split('.');
    return parts.map((p) {
      final m = RegExp(r'^(\d+)').firstMatch(p);
      return m != null ? int.parse(m.group(1)!) : 0;
    }).toList();
  }

  List<int> currentParts = parseVersion(currentVer);
  List<int> newParts = parseVersion(newVer);

  final maxLen = currentParts.length > newParts.length
      ? currentParts.length
      : newParts.length;
  for (int i = 0; i < maxLen; i++) {
    final cur = i < currentParts.length ? currentParts[i] : 0;
    final neu = i < newParts.length ? newParts[i] : 0;
    if (neu > cur) return true;
    if (neu < cur) return false;
  }

  if (checkBuild && !Platform.isLinux) {
    int parseBuild(String b) {
      try {
        final parsed = int.parse(b);
        return parsed > 1000 ? parsed % 1000 : parsed;
      } catch (_) {
        final m = RegExp(r'(\d+)').firstMatch(b);
        return m != null ? int.parse(m.group(1)!) : 0;
      }
    }

    final curBuild = parseBuild(currentBuild);
    final newBuildNum = parseBuild(newBuild);
    if (newBuildNum > curBuild) return true;
    if (newBuildNum < curBuild) return false;
  }

  return false;
}

Future<Map<String, dynamic>> sourceforgeUpdate(
    {Duration timeout = const Duration(seconds: 6)}) async {
  String platform = Platform.operatingSystem;
  if (platform != 'linux' && platform != 'android' && platform != 'win') {
    platform = 'win';
  }
  const url = 'https://sourceforge.net/projects/streambeats/best_release.json';
  final userAgent = {
    'win':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36',
    'linux':
        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3868.146 Safari/537.36 OPR/54.0.4087.46',
    'android':
        'Mozilla/5.0 (Linux; Android 13;) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36',
  };

  final headers = {
    'user-agent': userAgent['win']!,
    'accept': 'application/json, text/javascript, */*; q=0.01',
    'referer': 'https://sourceforge.net',
  };
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  try {
    final response =
        await http.get(Uri.parse(url), headers: headers).timeout(timeout);
    log("SourceForge response status code: ${response.statusCode}",
        name: 'UpdaterTools');
    if (response.statusCode == 403) {
      try {
        final snippet = response.body.length > 200
            ? response.body.substring(0, 200)
            : response.body;
        log('SourceForge 403 response snippet: $snippet', name: 'UpdaterTools');
      } catch (_) {}
      throw Exception('SourceForge returned 403');
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String platformKey = 'windows';
      if (Platform.isLinux) {
        platformKey = 'linux';
      } else if (Platform.isMacOS) {
        platformKey = 'mac';
      } else if (Platform.isAndroid) {
        platformKey = 'android';
      }

      Map? entry = (data['platform_releases'] is Map)
          ? (data['platform_releases'] as Map)[platformKey]
          : null;
      entry ??= data['release'];

      final releaseUrl = (entry != null && entry['url'] != null)
          ? entry['url'] as String
          : (data['release']?['url'] ?? '');
      String filename = (entry != null && entry['filename'] != null)
          ? entry['filename'] as String
          : (data['release']?['filename'] ?? '');

      try {
        filename = Uri.decodeFull(filename);
      } catch (_) {}
      String decodedUrl = releaseUrl;
      try {
        decodedUrl = Uri.decodeFull(releaseUrl);
      } catch (_) {}

      final versionRegex = RegExp(r'v(\d+(?:\.\d+)*)');
      final buildRegex = RegExp(r'\+(\d+)');

      Match? versionMatch = versionRegex.firstMatch(filename);
      versionMatch ??= versionRegex.firstMatch(decodedUrl);
      Match? buildMatch = buildRegex.firstMatch(filename);
      buildMatch ??= buildRegex.firstMatch(decodedUrl);

      final version = versionMatch?.group(1) ?? '';
      final build = buildMatch?.group(1) ?? '';

      return {
        'source': 'sourceforge',
        'newVer': version,
        'newBuild': build,
        'download_url': releaseUrl,
        'currVer': packageInfo.version,
        'currBuild': (int.tryParse(packageInfo.buildNumber) ?? 0) > 1000
            ? ((int.tryParse(packageInfo.buildNumber) ?? 0) % 1000).toString()
            : packageInfo.buildNumber,
        'results': isUpdateAvailable(
          packageInfo.version,
          packageInfo.buildNumber,
          version.isNotEmpty ? version : '0.0.0',
          build.isNotEmpty ? build : '0',
          checkBuild: platform == 'linux' ? false : true,
        ),
      };
    } else {
      throw Exception('SourceForge returned ${response.statusCode}');
    }
  } catch (e, st) {
    log('SourceForge update check failed: $e\n$st', name: 'UpdaterTools');
    rethrow;
  }
}

Future<Map<String, dynamic>> githubUpdate(
    {Duration timeout = const Duration(seconds: 6)}) async {
  final url =
      'https://api.github.com/repos/DuskCipher/StreamBeats/releases/latest';
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  try {
    final response = await http.get(Uri.parse(url)).timeout(timeout);
    log("GitHub response status code: ${response.statusCode}",
        name: 'UpdaterTools');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final tag = (data['tag_name'] as String?) ?? '';
      final tagParts = tag.split('+');
      final versionPart =
          tagParts.isNotEmpty ? tagParts[0].replaceFirst('v', '') : '';
      final buildPart = tagParts.length > 1 ? tagParts[1] : '';

      String? download = extractUpUrl(data);
      download ??= data['html_url'] ?? '';

      return {
        'source': 'github',
        'newVer': versionPart,
        'newBuild': buildPart,
        'download_url': download,
        'currVer': packageInfo.version,
        'currBuild': (int.tryParse(packageInfo.buildNumber) ?? 0) > 1000
            ? ((int.tryParse(packageInfo.buildNumber) ?? 0) % 1000).toString()
            : packageInfo.buildNumber,
        'results': isUpdateAvailable(
          packageInfo.version,
          packageInfo.buildNumber,
          versionPart.isNotEmpty ? versionPart : '0.0.0',
          buildPart.isNotEmpty ? buildPart : '0',
          checkBuild: true,
        ),
      };
    } else {
      throw Exception('GitHub returned ${response.statusCode}');
    }
  } catch (e, st) {
    log('GitHub update check failed: $e\n$st', name: 'UpdaterTools');
    rethrow;
  }
}

Future<Map<String, dynamic>> getAppUpdates() async {
  Map<String, dynamic> updates;
  try {
    updates = await githubUpdate();
  } catch (e) {
    log('GitHub check failed, trying SourceForge: $e', name: 'UpdaterTools');
    try {
      updates = await sourceforgeUpdate();
    } catch (e2) {
      log('SourceForge check failed: $e2', name: 'UpdaterTools');
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        updates = {
          'results': false,
          'error': 'Failed to check remote releases',
          'currVer': packageInfo.version,
          'currBuild': packageInfo.buildNumber,
          'source': 'none',
        };
      } catch (e3) {
        updates = {
          'results': false,
          'error':
              'Failed to check remote releases and failed to read local package info',
          'source': 'none',
        };
      }
    }
  }

  try {
    final readChangelogs = await SettingsDAO(DBProvider.db)
        .getSettingStr(SettingKeys.readChangelogs);
    final currVer = "v${updates['currVer']}";
    final newVer = "v${updates['newVer']}";

    log('Current version: $currVer, New version: $newVer, Read changelogs: $readChangelogs',
        name: 'UpdaterTools');

    if (currVer == newVer &&
        (readChangelogs == null || readChangelogs != currVer)) {
      final changelogText = await fetchChangelog();
      updates['changelogs'] = changelogText;
    } else {
      updates['changelogs'] = null;
    }
  } catch (e, st) {
    log('Attaching changelog failed: $e\n$st', name: 'UpdaterTools');
    updates['changelogs'] = null;
  }

  return updates;
}

Future<String?> fetchChangelog(
    {Duration timeout = const Duration(seconds: 6)}) async {
  const changelogUrl =
      'https://duskcipher.github.io/StreamBeats/CHANGELOG.md';
  try {
    final response = await http.get(Uri.parse(changelogUrl)).timeout(timeout);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      log('Changelog fetch returned status ${response.statusCode}',
          name: 'UpdaterTools');
      return null;
    }
  } catch (e, st) {
    log('Failed to fetch changelog: $e\n$st', name: 'UpdaterTools');
    return null;
  }
}

Future<Map<String, dynamic>> getLatestVersion() async => await getAppUpdates();

String? extractUpUrl(Map<String, dynamic> data) {

  for (var element in (data["assets"] as List)) {
    if (element["browser_download_url"].toString().contains("windows")) {
      if (Platform.isWindows) {
        return element["browser_download_url"].toString();
      }
    } else if (element["browser_download_url"].toString().contains("android")) {
      if (Platform.isAndroid) {
        return element["browser_download_url"].toString();
      }
    } else {
      continue;
    }
  }
  return null;
}