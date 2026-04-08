import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web not configured');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS not configured');
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDjN72zb90c8GzasTiFx-wZHKk_XbL2XPw',
    appId: '1:93914740482:android:976287a92168e91c1e741b',
    messagingSenderId: '93914740482',
    projectId: 'dgsell',
    storageBucket: 'dgsell.firebasestorage.app',
  );
}
