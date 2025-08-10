import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBWwGEpfjIkXNBlMLuSoO8Vg_zjxSzdwzA',
    appId: '1:742505244930:web:8f359eee21d3b9276a3a1b',
    messagingSenderId: '742505244930',
    projectId: 'fitgear-760eb',
    authDomain: 'fitgear-760eb.firebaseapp.com',
    storageBucket: 'fitgear-760eb.firebasestorage.app',
    measurementId: 'G-XXXXXXXXXX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBWwGEpfjIkXNBlMLuSoO8Vg_zjxSzdwzA',
    appId: '1:742505244930:android:8f359eee21d3b9276a3a1b',
    messagingSenderId: '742505244930',
    projectId: 'fitgear-760eb',
    storageBucket: 'fitgear-760eb.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBWwGEpfjIkXNBlMLuSoO8Vg_zjxSzdwzA',
    appId: '1:742505244930:ios:8f359eee21d3b9276a3a1b',
    messagingSenderId: '742505244930',
    projectId: 'fitgear-760eb',
    storageBucket: 'fitgear-760eb.firebasestorage.app',
    iosBundleId: 'com.test.FitGear',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBWwGEpfjIkXNBlMLuSoO8Vg_zjxSzdwzA',
    appId: '1:742505244930:ios:8f359eee21d3b9276a3a1b',
    messagingSenderId: '742505244930',
    projectId: 'fitgear-760eb',
    storageBucket: 'fitgear-760eb.firebasestorage.app',
    iosBundleId: 'com.test.FitGear',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBWwGEpfjIkXNBlMLuSoO8Vg_zjxSzdwzA',
    appId: '1:742505244930:web:8f359eee21d3b9276a3a1b',
    messagingSenderId: '742505244930',
    projectId: 'fitgear-760eb',
    authDomain: 'fitgear-760eb.firebaseapp.com',
    storageBucket: 'fitgear-760eb.firebasestorage.app',
    measurementId: 'G-XXXXXXXXXX',
  );
}
