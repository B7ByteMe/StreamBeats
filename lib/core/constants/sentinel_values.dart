library sentinel_values;

import 'package:streambeats/core/models/exported.dart';

final Track trackNull = Track(
  id: 'Null',
  title: 'Null',
  artists: const [],
  thumbnail: const Artwork(url: '', layout: ImageLayout.square),
  isExplicit: false,
);

bool isTrackNull(Track track) => track.id == 'Null' && track.title == 'Null';