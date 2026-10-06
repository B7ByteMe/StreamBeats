import 'package:streambeats/src/rust/api/plugin/commands.dart';

sealed class ContentEvent {
  const ContentEvent();
}

class SearchContent extends ContentEvent {
  final String query;
  final ContentSearchFilter filter;
  final String? pageToken;

  const SearchContent({
    required this.query,
    this.filter = ContentSearchFilter.all,
    this.pageToken,
  });
}

class LoadMoreSearchContent extends ContentEvent {
  final String pageToken;

  const LoadMoreSearchContent({required this.pageToken});
}

class SetActiveContentPlugin extends ContentEvent {
  final String pluginId;
  const SetActiveContentPlugin({required this.pluginId});
}

class LoadAlbumDetails extends ContentEvent {
  final String pluginId;
  final String albumId;
  const LoadAlbumDetails({required this.pluginId, required this.albumId});
}

class LoadMoreAlbumTracks extends ContentEvent {
  final String pluginId;
  final String albumId;
  final String pageToken;
  const LoadMoreAlbumTracks({
    required this.pluginId,
    required this.albumId,
    required this.pageToken,
  });
}

class LoadArtistDetails extends ContentEvent {
  final String pluginId;
  final String artistId;
  const LoadArtistDetails({required this.pluginId, required this.artistId});
}

class LoadMoreArtistAlbums extends ContentEvent {
  final String pluginId;
  final String artistId;
  final String pageToken;
  const LoadMoreArtistAlbums({
    required this.pluginId,
    required this.artistId,
    required this.pageToken,
  });
}

class LoadPlaylistDetails extends ContentEvent {
  final String pluginId;
  final String playlistId;
  const LoadPlaylistDetails({required this.pluginId, required this.playlistId});
}

class LoadMorePlaylistTracks extends ContentEvent {
  final String pluginId;
  final String playlistId;
  final String pageToken;
  const LoadMorePlaylistTracks({
    required this.pluginId,
    required this.playlistId,
    required this.pageToken,
  });
}

class GetStreams extends ContentEvent {
  final String pluginId;
  final String trackId;
  const GetStreams({required this.pluginId, required this.trackId});
}

class GetHomeSections extends ContentEvent {
  final String? pluginId;

  final bool bypassCache;

  const GetHomeSections({this.pluginId, this.bypassCache = false});
}

class LoadMoreHomeSectionItems extends ContentEvent {
  final String pluginId;
  final String sectionId;
  final String moreLink;
  const LoadMoreHomeSectionItems({
    required this.pluginId,
    required this.sectionId,
    required this.moreLink,
  });
}

class GetRadioTracks extends ContentEvent {
  final String pluginId;
  final String trackId;
  final String? pageToken;
  const GetRadioTracks({
    required this.pluginId,
    required this.trackId,
    this.pageToken,
  });
}

class ClearSearch extends ContentEvent {
  const ClearSearch();
}

class ClearDetails extends ContentEvent {
  const ClearDetails();
}

class ClearHomeSections extends ContentEvent {
  const ClearHomeSections();
}