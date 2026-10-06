import 'package:streambeats/core/models/exported.dart';
import 'package:streambeats/services/db/global_db.dart';
import 'package:streambeats/services/db/mappers/media_item_mapper.dart';

String playlistDBDisplayName(PlaylistDB playlistDB) {
  switch (playlistDB.type) {
    case PlaylistTypeDB.artist:
      return playlistDB.artists?.firstOrNull?.name?.trim().isNotEmpty == true
          ? playlistDB.artists!.first.name!.trim()
          : playlistDB.name;
    case PlaylistTypeDB.album:
      return playlistDB.album?.name.trim().isNotEmpty == true
          ? playlistDB.album!.name.trim()
          : playlistDB.name;
    case PlaylistTypeDB.remotePlaylist:
      return playlistDB.remotePlaylist?.name.trim().isNotEmpty == true
          ? playlistDB.remotePlaylist!.name.trim()
          : playlistDB.name;
    case PlaylistTypeDB.userPlaylist:
      return playlistDB.name;
  }
}

PlaylistDB artistSummaryToPlaylistDB(ArtistSummary artistSummary) {
  return PlaylistDB(
    name: artistSummary.id,
    album: null,
    artists: [artistSummaryToArtistSummaryDB(artistSummary)],
    type: PlaylistTypeDB.artist,
    createdat: DateTime.now(),
    thumbnail: artistSummary.thumbnail != null
        ? artworkToArtworkDB(artistSummary.thumbnail!)
        : null,
  );
}

ArtistSummary playlistDBToArtistSummary(PlaylistDB playlistDB) {
  final first = playlistDB.artists?.firstOrNull;
  return ArtistSummary(
    id: first?.mediaId ?? '',
    name: first?.name ?? 'Unknown',
    subtitle: first?.subtitle,
    thumbnail:
        first?.thumbnail != null ? artworkDBToArtwork(first!.thumbnail!) : null,
    url: first?.url,
  );
}

PlaylistDB albumSummaryToPlaylistDB(AlbumSummary albumSummary) {
  return PlaylistDB(
    name: albumSummary.id,
    album: albumSummaryToAlbumSummaryDB(albumSummary),
    artists: albumSummary.artists
        .map((a) => artistSummaryToArtistSummaryDB(a))
        .toList(),
    createdat: DateTime.now(),
    type: PlaylistTypeDB.album,
    thumbnail: albumSummary.thumbnail != null
        ? artworkToArtworkDB(albumSummary.thumbnail!)
        : null,
  );
}

AlbumSummary playlistDBToAlbumSummary(PlaylistDB playlistDB) {
  return AlbumSummary(
    id: playlistDB.album?.mediaId ?? '',
    title: playlistDBDisplayName(playlistDB),
    thumbnail: playlistDB.thumbnail != null
        ? artworkDBToArtwork(playlistDB.thumbnail!)
        : null,
    artists: playlistDB.artists != null
        ? playlistDB.artists!
            .map((a) => artistSummaryDBToArtistSummary(a))
            .toList()
        : [],
    url: playlistDB.album?.url,
    year: int.tryParse(playlistDB.album?.year ?? '') ?? 0,
  );
}

RemotePlaylistSummaryDB playlistSummaryToRemotePlaylistSummaryDB(
    PlaylistSummary playlistSummary) {
  return RemotePlaylistSummaryDB()
    ..mediaId = playlistSummary.id
    ..name = playlistSummary.title
    ..thumbnail = artworkToArtworkDB(playlistSummary.thumbnail)
    ..artists = playlistSummary.owner != null
        ? [
            ArtistSummaryDB()
              ..name = playlistSummary.owner!
              ..mediaId = ''
              ..subtitle = null
              ..thumbnail = null
              ..url = null,
          ]
        : null
    ..url = playlistSummary.url;
}

PlaylistDB playlistSummaryToPlaylistDB(PlaylistSummary playlistSummary) {
  return PlaylistDB(
    name: playlistSummary.id,
    remotePlaylist: playlistSummaryToRemotePlaylistSummaryDB(playlistSummary),
    album: null,
    artists: null,
    createdat: DateTime.now(),
    subtitle: playlistSummary.owner,
    description: null,
    thumbnail: artworkToArtworkDB(playlistSummary.thumbnail),
    type: PlaylistTypeDB.remotePlaylist,
    updatedat: null,
  );
}

PlaylistSummary playlistDBToPlaylistSummary(PlaylistDB playlistDB) {
  return PlaylistSummary(
    id: playlistDB.remotePlaylist?.mediaId ?? '',
    title: playlistDBDisplayName(playlistDB),
    thumbnail: playlistDB.thumbnail != null
        ? artworkDBToArtwork(playlistDB.thumbnail!)
        : const Artwork(url: '', layout: ImageLayout.square),
    url: playlistDB.remotePlaylist?.url,
    owner: (playlistDB.artists != null && playlistDB.artists!.isNotEmpty)
        ? playlistDB.artists!.map((a) => a.name).join(', ')
        : null,
  );
}

PlaylistSummary remotePlaylistSummaryDBToPlaylistSummary(
    RemotePlaylistSummaryDB r) {
  return PlaylistSummary(
    id: r.mediaId ?? '',
    title: r.name,
    thumbnail: r.thumbnail != null
        ? artworkDBToArtwork(r.thumbnail!)
        : const Artwork(url: '', layout: ImageLayout.square),
    url: r.url,
    owner: (r.artists != null && r.artists!.isNotEmpty)
        ? r.artists!.map((a) => a.name).join(', ')
        : null,
  );
}