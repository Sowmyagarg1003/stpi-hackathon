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
    apiKey: "AIzaSyAAeJ0boY6dqXcK8ntpTdP5HwNLLnL76oo",
    authDomain: "code-catalysts.firebaseapp.com",
    projectId: "code-catalysts",
    storageBucket: "code-catalysts.appspot.com",
    messagingSenderId: "33787728039",
    appId: "1:33787728039:web:7bb22366d02c624eb74b82",
    measurementId: "G-5WHW1TF34X",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyAbHRwOPnN2Wq_yrA4BHXoisHLVxqC0X30",
    appId: "1:33787728039:android:ab6672769c408103b74b82",
    messagingSenderId: "33787728039",
    projectId: "code-catalysts",
    storageBucket: "code-catalysts.appspot.com",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyC9LdhTuykgfyKxoTRhgp6KH3ctXOkHzdk",
    appId: "1:33787728039:ios:dff666d0bcca6e55b74b82",
    messagingSenderId: "33787728039",
    projectId: "code-catalysts",
    storageBucket: "code-catalysts.appspot.com",
    //iosClientId:
    //'184595400107-5bvpcsqbapnsnb5u6fqrp86kr597hpvu.apps.googleusercontent.com',
    iosBundleId: "com.example.transactionsApp",
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: "AIzaSyC9LdhTuykgfyKxoTRhgp6KH3ctXOkHzdk",
    appId: "1:33787728039:ios:dff666d0bcca6e55b74b82",
    messagingSenderId: "33787728039",
    projectId: "code-catalysts",
    storageBucket: "code-catalysts.appspot.com",
    //iosClientId:
    //'184595400107-5bvpcsqbapnsnb5u6fqrp86kr597hpvu.apps.googleusercontent.com',
    iosBundleId: "com.example.transactionsApp",
  );
}
