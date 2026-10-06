part of 'models.dart';

T _$identity<T>(T value) => value;

mixin _$MediaItem {
  Object get field0;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MediaItem &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @override
  String toString() {
    return 'MediaItem(field0: $field0)';
  }
}

class $MediaItemCopyWith<$Res> {
  $MediaItemCopyWith(MediaItem _, $Res Function(MediaItem) __);
}

extension MediaItemPatterns on MediaItem {

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MediaItem_Track value)? track,
    TResult Function(MediaItem_Album value)? album,
    TResult Function(MediaItem_Artist value)? artist,
    TResult Function(MediaItem_Playlist value)? playlist,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case MediaItem_Track() when track != null:
        return track(_that);
      case MediaItem_Album() when album != null:
        return album(_that);
      case MediaItem_Artist() when artist != null:
        return artist(_that);
      case MediaItem_Playlist() when playlist != null:
        return playlist(_that);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MediaItem_Track value) track,
    required TResult Function(MediaItem_Album value) album,
    required TResult Function(MediaItem_Artist value) artist,
    required TResult Function(MediaItem_Playlist value) playlist,
  }) {
    final _that = this;
    switch (_that) {
      case MediaItem_Track():
        return track(_that);
      case MediaItem_Album():
        return album(_that);
      case MediaItem_Artist():
        return artist(_that);
      case MediaItem_Playlist():
        return playlist(_that);
    }
  }

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MediaItem_Track value)? track,
    TResult? Function(MediaItem_Album value)? album,
    TResult? Function(MediaItem_Artist value)? artist,
    TResult? Function(MediaItem_Playlist value)? playlist,
  }) {
    final _that = this;
    switch (_that) {
      case MediaItem_Track() when track != null:
        return track(_that);
      case MediaItem_Album() when album != null:
        return album(_that);
      case MediaItem_Artist() when artist != null:
        return artist(_that);
      case MediaItem_Playlist() when playlist != null:
        return playlist(_that);
      case _:
        return null;
    }
  }

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Track field0)? track,
    TResult Function(AlbumSummary field0)? album,
    TResult Function(ArtistSummary field0)? artist,
    TResult Function(PlaylistSummary field0)? playlist,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case MediaItem_Track() when track != null:
        return track(_that.field0);
      case MediaItem_Album() when album != null:
        return album(_that.field0);
      case MediaItem_Artist() when artist != null:
        return artist(_that.field0);
      case MediaItem_Playlist() when playlist != null:
        return playlist(_that.field0);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Track field0) track,
    required TResult Function(AlbumSummary field0) album,
    required TResult Function(ArtistSummary field0) artist,
    required TResult Function(PlaylistSummary field0) playlist,
  }) {
    final _that = this;
    switch (_that) {
      case MediaItem_Track():
        return track(_that.field0);
      case MediaItem_Album():
        return album(_that.field0);
      case MediaItem_Artist():
        return artist(_that.field0);
      case MediaItem_Playlist():
        return playlist(_that.field0);
    }
  }

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Track field0)? track,
    TResult? Function(AlbumSummary field0)? album,
    TResult? Function(ArtistSummary field0)? artist,
    TResult? Function(PlaylistSummary field0)? playlist,
  }) {
    final _that = this;
    switch (_that) {
      case MediaItem_Track() when track != null:
        return track(_that.field0);
      case MediaItem_Album() when album != null:
        return album(_that.field0);
      case MediaItem_Artist() when artist != null:
        return artist(_that.field0);
      case MediaItem_Playlist() when playlist != null:
        return playlist(_that.field0);
      case _:
        return null;
    }
  }
}

class MediaItem_Track extends MediaItem {
  const MediaItem_Track(this.field0) : super._();

  @override
  final Track field0;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MediaItem_TrackCopyWith<MediaItem_Track> get copyWith =>
      _$MediaItem_TrackCopyWithImpl<MediaItem_Track>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MediaItem_Track &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'MediaItem.track(field0: $field0)';
  }
}

abstract mixin class $MediaItem_TrackCopyWith<$Res>
    implements $MediaItemCopyWith<$Res> {
  factory $MediaItem_TrackCopyWith(
          MediaItem_Track value, $Res Function(MediaItem_Track) _then) =
      _$MediaItem_TrackCopyWithImpl;
  @useResult
  $Res call({Track field0});
}

class _$MediaItem_TrackCopyWithImpl<$Res>
    implements $MediaItem_TrackCopyWith<$Res> {
  _$MediaItem_TrackCopyWithImpl(this._self, this._then);

  final MediaItem_Track _self;
  final $Res Function(MediaItem_Track) _then;

  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(MediaItem_Track(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as Track,
    ));
  }
}

class MediaItem_Album extends MediaItem {
  const MediaItem_Album(this.field0) : super._();

  @override
  final AlbumSummary field0;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MediaItem_AlbumCopyWith<MediaItem_Album> get copyWith =>
      _$MediaItem_AlbumCopyWithImpl<MediaItem_Album>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MediaItem_Album &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'MediaItem.album(field0: $field0)';
  }
}

abstract mixin class $MediaItem_AlbumCopyWith<$Res>
    implements $MediaItemCopyWith<$Res> {
  factory $MediaItem_AlbumCopyWith(
          MediaItem_Album value, $Res Function(MediaItem_Album) _then) =
      _$MediaItem_AlbumCopyWithImpl;
  @useResult
  $Res call({AlbumSummary field0});
}

class _$MediaItem_AlbumCopyWithImpl<$Res>
    implements $MediaItem_AlbumCopyWith<$Res> {
  _$MediaItem_AlbumCopyWithImpl(this._self, this._then);

  final MediaItem_Album _self;
  final $Res Function(MediaItem_Album) _then;

  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(MediaItem_Album(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as AlbumSummary,
    ));
  }
}

class MediaItem_Artist extends MediaItem {
  const MediaItem_Artist(this.field0) : super._();

  @override
  final ArtistSummary field0;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MediaItem_ArtistCopyWith<MediaItem_Artist> get copyWith =>
      _$MediaItem_ArtistCopyWithImpl<MediaItem_Artist>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MediaItem_Artist &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'MediaItem.artist(field0: $field0)';
  }
}

abstract mixin class $MediaItem_ArtistCopyWith<$Res>
    implements $MediaItemCopyWith<$Res> {
  factory $MediaItem_ArtistCopyWith(
          MediaItem_Artist value, $Res Function(MediaItem_Artist) _then) =
      _$MediaItem_ArtistCopyWithImpl;
  @useResult
  $Res call({ArtistSummary field0});
}

class _$MediaItem_ArtistCopyWithImpl<$Res>
    implements $MediaItem_ArtistCopyWith<$Res> {
  _$MediaItem_ArtistCopyWithImpl(this._self, this._then);

  final MediaItem_Artist _self;
  final $Res Function(MediaItem_Artist) _then;

  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(MediaItem_Artist(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as ArtistSummary,
    ));
  }
}

class MediaItem_Playlist extends MediaItem {
  const MediaItem_Playlist(this.field0) : super._();

  @override
  final PlaylistSummary field0;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MediaItem_PlaylistCopyWith<MediaItem_Playlist> get copyWith =>
      _$MediaItem_PlaylistCopyWithImpl<MediaItem_Playlist>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MediaItem_Playlist &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'MediaItem.playlist(field0: $field0)';
  }
}

abstract mixin class $MediaItem_PlaylistCopyWith<$Res>
    implements $MediaItemCopyWith<$Res> {
  factory $MediaItem_PlaylistCopyWith(
          MediaItem_Playlist value, $Res Function(MediaItem_Playlist) _then) =
      _$MediaItem_PlaylistCopyWithImpl;
  @useResult
  $Res call({PlaylistSummary field0});
}

class _$MediaItem_PlaylistCopyWithImpl<$Res>
    implements $MediaItem_PlaylistCopyWith<$Res> {
  _$MediaItem_PlaylistCopyWithImpl(this._self, this._then);

  final MediaItem_Playlist _self;
  final $Res Function(MediaItem_Playlist) _then;

  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(MediaItem_Playlist(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as PlaylistSummary,
    ));
  }
}

mixin _$Suggestion {
  Object get field0;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Suggestion &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @override
  String toString() {
    return 'Suggestion(field0: $field0)';
  }
}

class $SuggestionCopyWith<$Res> {
  $SuggestionCopyWith(Suggestion _, $Res Function(Suggestion) __);
}

extension SuggestionPatterns on Suggestion {

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Suggestion_Query value)? query,
    TResult Function(Suggestion_Entity value)? entity,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case Suggestion_Query() when query != null:
        return query(_that);
      case Suggestion_Entity() when entity != null:
        return entity(_that);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Suggestion_Query value) query,
    required TResult Function(Suggestion_Entity value) entity,
  }) {
    final _that = this;
    switch (_that) {
      case Suggestion_Query():
        return query(_that);
      case Suggestion_Entity():
        return entity(_that);
    }
  }

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Suggestion_Query value)? query,
    TResult? Function(Suggestion_Entity value)? entity,
  }) {
    final _that = this;
    switch (_that) {
      case Suggestion_Query() when query != null:
        return query(_that);
      case Suggestion_Entity() when entity != null:
        return entity(_that);
      case _:
        return null;
    }
  }

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? query,
    TResult Function(EntitySuggestion field0)? entity,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case Suggestion_Query() when query != null:
        return query(_that.field0);
      case Suggestion_Entity() when entity != null:
        return entity(_that.field0);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) query,
    required TResult Function(EntitySuggestion field0) entity,
  }) {
    final _that = this;
    switch (_that) {
      case Suggestion_Query():
        return query(_that.field0);
      case Suggestion_Entity():
        return entity(_that.field0);
    }
  }

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field0)? query,
    TResult? Function(EntitySuggestion field0)? entity,
  }) {
    final _that = this;
    switch (_that) {
      case Suggestion_Query() when query != null:
        return query(_that.field0);
      case Suggestion_Entity() when entity != null:
        return entity(_that.field0);
      case _:
        return null;
    }
  }
}

class Suggestion_Query extends Suggestion {
  const Suggestion_Query(this.field0) : super._();

  @override
  final String field0;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $Suggestion_QueryCopyWith<Suggestion_Query> get copyWith =>
      _$Suggestion_QueryCopyWithImpl<Suggestion_Query>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Suggestion_Query &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'Suggestion.query(field0: $field0)';
  }
}

abstract mixin class $Suggestion_QueryCopyWith<$Res>
    implements $SuggestionCopyWith<$Res> {
  factory $Suggestion_QueryCopyWith(
          Suggestion_Query value, $Res Function(Suggestion_Query) _then) =
      _$Suggestion_QueryCopyWithImpl;
  @useResult
  $Res call({String field0});
}

class _$Suggestion_QueryCopyWithImpl<$Res>
    implements $Suggestion_QueryCopyWith<$Res> {
  _$Suggestion_QueryCopyWithImpl(this._self, this._then);

  final Suggestion_Query _self;
  final $Res Function(Suggestion_Query) _then;

  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(Suggestion_Query(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

class Suggestion_Entity extends Suggestion {
  const Suggestion_Entity(this.field0) : super._();

  @override
  final EntitySuggestion field0;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $Suggestion_EntityCopyWith<Suggestion_Entity> get copyWith =>
      _$Suggestion_EntityCopyWithImpl<Suggestion_Entity>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Suggestion_Entity &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'Suggestion.entity(field0: $field0)';
  }
}

abstract mixin class $Suggestion_EntityCopyWith<$Res>
    implements $SuggestionCopyWith<$Res> {
  factory $Suggestion_EntityCopyWith(
          Suggestion_Entity value, $Res Function(Suggestion_Entity) _then) =
      _$Suggestion_EntityCopyWithImpl;
  @useResult
  $Res call({EntitySuggestion field0});
}

class _$Suggestion_EntityCopyWithImpl<$Res>
    implements $Suggestion_EntityCopyWith<$Res> {
  _$Suggestion_EntityCopyWithImpl(this._self, this._then);

  final Suggestion_Entity _self;
  final $Res Function(Suggestion_Entity) _then;

  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(Suggestion_Entity(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as EntitySuggestion,
    ));
  }
}