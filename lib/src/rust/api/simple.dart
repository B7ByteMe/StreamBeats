import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

String greet({required String name}) =>
    RustLib.instance.api.crateApiBridgeGreet(name: name);