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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBTG2QXGepxNeQJAJUQMID1Ez33I83KKwo',
    appId: '1:938312015413:web:a475d2755cb78bb9421b7c',
    messagingSenderId: '938312015413',
    projectId: 'todo-app-28551',
    authDomain: 'todo-app-28551.firebaseapp.com',
    databaseURL: 'https://todo-app-28551-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'todo-app-28551.appspot.com',
    measurementId: 'G-BT39H3S4FK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB_1cZWpJTsJ-XAaX8ADUmBo7iCiSqp3tY',
    appId: '1:938312015413:android:157297e465cafe3a421b7c',
    messagingSenderId: '938312015413',
    projectId: 'todo-app-28551',
    databaseURL: 'https://todo-app-28551-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'todo-app-28551.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDUAJ3NnWrtclM1kO67nIEplNtAxxy-Jys',
    appId: '1:938312015413:ios:e7457114cd70c45d421b7c',
    messagingSenderId: '938312015413',
    projectId: 'todo-app-28551',
    databaseURL: 'https://todo-app-28551-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'todo-app-28551.appspot.com',
    androidClientId: '938312015413-he10jmq5pr7fid3r3ds473rqt934ona0.apps.googleusercontent.com',
    iosClientId: '938312015413-7nck6dr91fj8jola3uub0049dgcmi60o.apps.googleusercontent.com',
    iosBundleId: 'com.example.todoApp',
  );
}
