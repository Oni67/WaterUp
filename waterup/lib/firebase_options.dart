// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBps2exeZbY5JzWCBiD029cA34HhlzbMHw',
    appId: '1:85759773266:web:88bfa5194190fa1e78ad8b',
    messagingSenderId: '85759773266',
    projectId: 'waterup-93661',
    authDomain: 'waterup-93661.firebaseapp.com',
    storageBucket: 'waterup-93661.appspot.com',
    measurementId: 'G-4FJ1C54D8V',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDGvNYOxxeYmwVbJA0M8bunbHGd3jn4Gvg',
    appId: '1:85759773266:android:bc22b4a22854d9ef78ad8b',
    messagingSenderId: '85759773266',
    projectId: 'waterup-93661',
    storageBucket: 'waterup-93661.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCXfmj1TKEG_HaBxvwFims_ML_pl-xIRts',
    appId: '1:85759773266:ios:64a4e17ef5056d1d78ad8b',
    messagingSenderId: '85759773266',
    projectId: 'waterup-93661',
    storageBucket: 'waterup-93661.appspot.com',
    iosBundleId: 'com.example.waterup',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCXfmj1TKEG_HaBxvwFims_ML_pl-xIRts',
    appId: '1:85759773266:ios:7d8c68d248028ff078ad8b',
    messagingSenderId: '85759773266',
    projectId: 'waterup-93661',
    storageBucket: 'waterup-93661.appspot.com',
    iosBundleId: 'com.example.waterup.RunnerTests',
  );
}
