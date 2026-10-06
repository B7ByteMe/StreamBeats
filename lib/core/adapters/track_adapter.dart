library track_adapter;

import 'dart:io';

import 'package:streambeats/core/models/exported.dart' hide MediaItem;
import 'package:streambeats/core/models/media_playlist_model.dart';
import 'package:audio_service/audio_service.dart';

MediaItem trackToMediaItem(Track track) {
  final artistStr = track.artists.isNotEmpty
      ? track.artists.map((a) => a.name).join(', ')
      : 'Unknown Artist';

  return MediaItem(
    id: track.id,
    title: track.title,
    album: track.album?.title ?? '',
    artist: artistStr,
    artUri: _safeArtUri(track.thumbnail.url),
    duration: track.durationMs != null
        ? Duration(milliseconds: track.durationMs!.toInt())
        : null,
    extras: <String, dynamic>{
      'isExplicit': track.isExplicit,
      'thumbnailUrl': track.thumbnail.url,
      'thumbnailUrlLow': track.thumbnail.urlLow,
      'thumbnailUrlHigh': track.thumbnail.urlHigh,
    },
  );
}

Uri? _safeArtUri(String url) {
  if (url.isEmpty) return null;

  final trimmed = url.trim();

  if (trimmed.startsWith('/') || RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(trimmed)) {
    try {
      final file = File(trimmed);
      if (file.existsSync()) return Uri.file(trimmed);
    } catch (_) {}
    return null;
  }

  final uri = Uri.tryParse(trimmed);
  if (uri == null) return null;

  if (uri.scheme == 'file') {
    try {
      final path = uri.toFilePath();
      if (File(path).existsSync()) return uri;
    } catch (_) {}
    return null;
  }

  if ((uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty) {
    return uri;
  }

  return null;
}

Track mediaItemToTrack(MediaItem mi) {
  final artists = (mi.artist ?? '')
      .split(', ')
      .where((s) => s.isNotEmpty)
      .map((name) => ArtistSummary(id: '', name: name))
      .toList();

  return Track(
    id: mi.id,
    title: mi.title,
    artists: artists,
    album: mi.album != null
        ? AlbumSummary(id: '', title: mi.album!, artists: [])
        : null,
    thumbnail: Artwork(
      url: mi.artUri?.toString() ?? '',
      layout: ImageLayout.square,
    ),
    durationMs:
        mi.duration != null ? BigInt.from(mi.duration!.inMilliseconds) : null,
    isExplicit: mi.extras?['isExplicit'] as bool? ?? false,
  );
}

Playlist tracksToPlaylist(
  String title,
  List<Track> tracks, {
  Artwork? thumbnail,
  String? description,
  PlaylistType type = PlaylistType.userPlaylist,
}) {
  return Playlist(
    title: title,
    tracks: tracks,
    thumbnail: thumbnail,
    description: description,
    type: type,
  );
}