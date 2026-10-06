import 'package:streambeats/l10n/app_localizations.dart';
import 'dart:io';

void main() {
  final dir = Directory('lib/l10n');
  final files = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.arb'));
  for (final file in files) {
    String content = file.readAsStringSync();
    if (content.contains(' 😍')) {
      content = content.replaceAll(' 😍', '');
      file.writeAsStringSync(content);
      print('Updated ${file.path}');
    }
  }
}
