// Firebase configuration for Agent Mitra
// This is a placeholder configuration for development
// Replace with actual Firebase project configuration when available

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        return web; // fallback
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:123456789:web:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'agent-mitra-demo',
    authDomain: 'agent-mitra-demo.firebaseapp.com',
    storageBucket: 'agent-mitra-demo.appspot.com',
    measurementId: 'G-ABCDEFGHIJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:123456789:android:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'agent-mitra-demo',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:123456789:ios:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'agent-mitra-demo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:123456789:macos:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'agent-mitra-demo',
  );
}
