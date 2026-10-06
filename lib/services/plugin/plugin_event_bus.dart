import 'dart:async';
import 'dart:developer';

import 'package:streambeats/src/rust/api/plugin/events.dart';
import 'package:streambeats/src/rust/api/plugin/plugin.dart';
import 'package:streambeats/src/rust/api/bridge.dart' as bridge;

class PluginEventBus {
  PluginEventBus._();

  static final PluginEventBus instance = PluginEventBus._();

  final StreamController<PluginManagerEvent> _controller =
      StreamController<PluginManagerEvent>.broadcast();

  StreamSubscription<PluginManagerEvent>? _rustSubscription;

  bool _connected = false;

  bool get isConnected => _connected;

  Stream<PluginManagerEvent> get events => _controller.stream;

  void connect(PluginManager manager) {
    if (_connected) {
      log('PluginEventBus already connected — ignoring duplicate connect call',
          name: 'PluginEventBus');
      return;
    }

    final rustStream = bridge.initPluginEventStream(manager: manager);

    _rustSubscription = rustStream.listen(
      (event) {
        log('PluginEvent: $event', name: 'PluginEventBus');
        _controller.add(event);
      },
      onError: (Object error, StackTrace stack) {
        log('PluginEventBus stream error: $error',
            name: 'PluginEventBus', error: error, stackTrace: stack);
      },
      onDone: () {
        log('PluginEventBus: Rust event stream closed', name: 'PluginEventBus');
        _connected = false;
      },
    );

    _connected = true;
    log('PluginEventBus connected to Rust event stream',
        name: 'PluginEventBus');
  }

  void dispose() {
    _rustSubscription?.cancel();
    _rustSubscription = null;
    _controller.close();
    _connected = false;
    log('PluginEventBus disposed', name: 'PluginEventBus');
  }
}