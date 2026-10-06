import 'package:flutter_bloc/flutter_bloc.dart';

class PlayerOverlayCubit extends Cubit<bool> {
  PlayerOverlayCubit() : super(false);

  bool Function()? _collapseUpNextPanel;

  void registerUpNextPanelCollapse(bool Function() collapse) {
    _collapseUpNextPanel = collapse;
  }

  void unregisterUpNextPanelCollapse() {
    _collapseUpNextPanel = null;
  }

  bool collapseUpNextPanel() {
    return _collapseUpNextPanel?.call() ?? false;
  }

  void showPlayer() => emit(true);

  void hidePlayer() => emit(false);

  void togglePlayer() => emit(!state);

  bool get isPlayerVisible => state;
}