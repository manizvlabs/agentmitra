import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

// Conditional imports for connectivity
class ConnectivityService {
  static bool get isConnected {
    // For web, assume always connected
    if (kIsWeb) {
      return true;
    }
    // For mobile, we would use connectivity_plus, but for now return true
    return true;
  }

  static Stream<bool> get onConnectivityChanged {
    // For web, return a stream that always emits true
    if (kIsWeb) {
      return Stream.value(true);
    }
    // For mobile, we would use connectivity_plus stream
    return Stream.value(true);
  }
}
