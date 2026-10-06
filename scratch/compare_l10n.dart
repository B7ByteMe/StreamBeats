import 'dart:convert';
import 'dart:io';

void main() {
  final enFile = File('d:/StreamBeats/lib/l10n/app_en.arb');
  final idFile = File('d:/StreamBeats/lib/l10n/app_id.arb');

  final en = json.decode(enFile.readAsStringSync()) as Map<String, dynamic>;
  final id = json.decode(idFile.readAsStringSync()) as Map<String, dynamic>;

  final missing = <String>[];
  for (final key in en.keys) {
    if (!id.containsKey(key)) {
      missing.add(key);
    }
  }

  print('Total keys in EN: ${en.length}');
  print('Total keys in ID: ${id.length}');
  print('Missing keys in ID (${missing.length}):');
  for (final key in missing) {
    print('- $key: ${en[key]}');
  }
}
