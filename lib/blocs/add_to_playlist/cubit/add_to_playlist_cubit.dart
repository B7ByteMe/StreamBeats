import 'package:bloc/bloc.dart';
import 'package:streambeats/core/models/exported.dart';
import 'package:streambeats/core/constants/sentinel_values.dart';

part 'add_to_playlist_state.dart';

class AddToPlaylistCubit extends Cubit<AddToPlaylistState> {
  AddToPlaylistCubit() : super(AddToPlaylistInitial());

  void setTrack(Track track) {
    emit(state.copyWith(track: track));
  }
}