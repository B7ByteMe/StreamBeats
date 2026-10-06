import 'package:equatable/equatable.dart';

import 'package:streambeats/src/rust/api/plugin/models.dart';

enum ImportPhase {
  idle,
  checkingUrl,
  fetchingInfo,
  fetchingTracks,
  resolving,
  review,
  saving,
  done,
  error,
}

enum TrackResolutionStatus {
  pending,
  resolving,
  resolved,
  failed,
}

class ImportTrackEntry extends Equatable {
  final ImportTrackItem sourceTrack;
  final TrackResolutionStatus status;

  final Track? resolvedTrack;

  final List<Track> candidates;

  final int? selectedCandidateIndex;

  const ImportTrackEntry({
    required this.sourceTrack,
    this.status = TrackResolutionStatus.pending,
    this.resolvedTrack,
    this.candidates = const [],
    this.selectedCandidateIndex,
  });

  bool get isSkipped => selectedCandidateIndex == -1;

  Track? get effectiveTrack {
    if (isSkipped) return null;
    final idx = selectedCandidateIndex;
    if (idx != null && idx >= 0 && idx < candidates.length) {
      return candidates[idx];
    }
    return resolvedTrack;
  }

  ImportTrackEntry copyWith({
    TrackResolutionStatus? status,
    Track? resolvedTrack,
    List<Track>? candidates,
    int? selectedCandidateIndex,
    bool clearSelection = false,
  }) {
    return ImportTrackEntry(
      sourceTrack: sourceTrack,
      status: status ?? this.status,
      resolvedTrack: resolvedTrack ?? this.resolvedTrack,
      candidates: candidates ?? this.candidates,
      selectedCandidateIndex: clearSelection
          ? null
          : (selectedCandidateIndex ?? this.selectedCandidateIndex),
    );
  }

  @override
  List<Object?> get props =>
      [sourceTrack, status, resolvedTrack, candidates, selectedCandidateIndex];
}

class ContentImportState extends Equatable {
  final ImportPhase phase;
  final String? pluginId;
  final String? url;
  final ImportCollectionSummary? collectionInfo;
  final List<ImportTrackEntry> tracks;
  final int resolvedCount;
  final int failedCount;
  final String? error;

  const ContentImportState({
    this.phase = ImportPhase.idle,
    this.pluginId,
    this.url,
    this.collectionInfo,
    this.tracks = const [],
    this.resolvedCount = 0,
    this.failedCount = 0,
    this.error,
  });

  ContentImportState copyWith({
    ImportPhase? phase,
    String? pluginId,
    String? url,
    ImportCollectionSummary? collectionInfo,
    List<ImportTrackEntry>? tracks,
    int? resolvedCount,
    int? failedCount,
    String? error,
    bool clearError = false,
  }) {
    return ContentImportState(
      phase: phase ?? this.phase,
      pluginId: pluginId ?? this.pluginId,
      url: url ?? this.url,
      collectionInfo: collectionInfo ?? this.collectionInfo,
      tracks: tracks ?? this.tracks,
      resolvedCount: resolvedCount ?? this.resolvedCount,
      failedCount: failedCount ?? this.failedCount,
      error: clearError ? null : (error ?? this.error),
    );
  }

  int get totalTracks => tracks.length;

  @override
  List<Object?> get props => [
        phase,
        pluginId,
        url,
        collectionInfo,
        tracks,
        resolvedCount,
        failedCount,
        error,
      ];
}