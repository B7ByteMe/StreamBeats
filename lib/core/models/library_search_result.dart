import 'package:streambeats/core/models/exported.dart';

class SongSearchResult {
  final Track song;
  final String playlistName;

  const SongSearchResult({
    required this.song,
    required this.playlistName,
  });
}
