import 'dart:async';
import 'dart:developer';

import 'package:streambeats/core/models/exported.dart';
import 'package:streambeats/services/db/dao/history_dao.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'recently_state.dart';

class RecentlyCubit extends Cubit<RecentlyCubitState> {
  final HistoryDAO _historyDao;
  StreamSubscription<void>? _watcher;

  RecentlyCubit(this._historyDao) : super(RecentlyCubitInitial()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _fetchHistory();
    await _watchHistory();
  }

  Future<void> _watchHistory() async {
    _watcher = (await _historyDao.watchHistory()).listen((_) {
      _fetchHistory();
      log('Recently Played Updated', name: 'RecentlyCubit');
    });
  }

  @override
  Future<void> close() {
    _watcher?.cancel();
    return super.close();
  }

  Future<void> _fetchHistory() async {
    final tracks = await _historyDao.getHistory(limit: 15);
    emit(state.copyWith(tracks: tracks));
  }
}