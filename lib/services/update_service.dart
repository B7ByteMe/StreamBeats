import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'dart:convert';

import 'package:streambeats/screens/widgets/snackbar.dart';

class UpdateService {
  static bool _updateChecked = false;

  /// Checks for updates. Assumes update metadata is stored at:
  /// https://streambeats.valoraofficial.workers.dev/update.json
  static Future<void> checkUpdate(BuildContext context) async {
    if (_updateChecked) return;
    _updateChecked = true;

    try {
      final response = await http.get(
        Uri.parse('https://streambeats.valoraofficial.workers.dev/update.json'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) return;

      final data = json.decode(response.body);
      final String serverVersion = data['version'] ?? '3.2.1';
      final int serverBuild = data['buildNumber'] ?? 2;
      final String apkUrl = data['apkUrl'] ?? '';
      final String webUrl = data['webUrl'] ?? 'https://streambeats.valoraofficial.workers.dev/';
      final String changelog = data['changelog'] ?? 'Pembaruan versi terbaru.';

      // Get current app version details
      final packageInfo = await PackageInfo.fromPlatform();
      final int currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;

      if (serverBuild > currentBuild) {
        if (context.mounted) {
          showUpdateDialog(context, serverVersion, webUrl, apkUrl, changelog);
        }
      }
    } catch (e) {
      // Fail silently for update checks so it doesn't disturb user experience
      debugPrint('Error checking update: $e');
    }
  }

  static void showUpdateDialog(
    BuildContext context,
    String serverVersion,
    String webUrl,
    String apkUrl,
    String changelog,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161618),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.system_update_rounded, color: Colors.purpleAccent, size: 28),
            const SizedBox(width: 10),
            Text(
              'Pembaruan Tersedia v$serverVersion',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apa yang baru:',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              changelog,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pilih metode untuk memperbarui aplikasi Anda.',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          // Option 1: Open Official Web
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final uri = Uri.parse(webUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('Buka Web Resmi', style: TextStyle(color: Colors.grey)),
          ),
          // Option 2: Download inside application
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _startInAppDownload(context, apkUrl, serverVersion);
            },
            child: const Text('Perbarui Langsung', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  static void _startInAppDownload(BuildContext context, String apkUrl, String version) {
    if (apkUrl.isEmpty) {
      SnackbarService.showMessage('Link download APK tidak valid.');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _DownloadProgressDialog(apkUrl: apkUrl, version: version),
    );
  }
}

class _DownloadProgressDialog extends StatefulWidget {
  final String apkUrl;
  final String version;

  const _DownloadProgressDialog({
    Key? key,
    required this.apkUrl,
    required this.version,
  }) : super(key: key);

  @override
  State<_DownloadProgressDialog> createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<_DownloadProgressDialog> {
  double progress = 0.0;
  String progressText = "Menghubungkan...";
  late http.Client client;
  bool _downloadStarted = false;

  @override
  void initState() {
    super.initState();
    client = http.Client();
    _startDownload();
  }

  @override
  void dispose() {
    client.close();
    super.dispose();
  }

  Future<void> _startDownload() async {
    if (_downloadStarted) return;
    _downloadStarted = true;

    try {
      if (Platform.isAndroid) {
        final status = await Permission.requestInstallPackages.status;
        if (status.isDenied) {
          await Permission.requestInstallPackages.request();
        }
      }

      final request = http.Request('GET', Uri.parse(widget.apkUrl));
      final response = await client.send(request).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Gagal menghubungi server update: ${response.statusCode}');
      }

      final contentLength = response.contentLength ?? 0;
      final List<int> bytes = [];

      response.stream.listen(
        (chunk) {
          bytes.addAll(chunk);
          if (contentLength > 0 && mounted) {
            setState(() {
              progress = bytes.length / contentLength;
              progressText = "Mengunduh... ${(progress * 100).toStringAsFixed(0)}%";
            });
          }
        },
        onDone: () async {
          if (!mounted) return;
          setState(() {
            progressText = "Menyimpan file...";
          });

          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/StreamBeats_v${widget.version}.apk');
          await file.writeAsBytes(bytes);

          if (!mounted) return;
          setState(() {
            progressText = "Memasang aplikasi...";
          });

          Navigator.pop(context); // Close the download dialog

          final openResult = await OpenFile.open(file.path);
          if (openResult.type != ResultType.done) {
            SnackbarService.showMessage('Gagal membuka file APK: ${openResult.message}');
          }
        },
        onError: (e) {
          if (mounted) {
            Navigator.pop(context);
          }
          SnackbarService.showMessage('Gagal mengunduh: $e');
        },
        cancelOnError: true,
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
      }
      SnackbarService.showMessage('Gagal mengunduh update: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF161618),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Mengunduh Pembaruan',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: progress > 0 ? progress : null,
            color: Colors.purpleAccent,
            backgroundColor: Colors.white10,
          ),
          const SizedBox(height: 16),
          Text(
            progressText,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
