import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class FirebaseNotificationController {
  static final _instance = FirebaseNotificationController();
  final _firebaseMessaging = FirebaseMessaging.instance;

  FirebaseNotificationController();

  static FirebaseNotificationController getRef() => _instance;

  init() async {
    await _firebaseMessaging.requestPermission();
    var token = getToken();
    initPushNotification();
  }


  getToken() async {
    final fcmToken = await _firebaseMessaging.getToken();
    return fcmToken;
  }

  handleMessage(RemoteMessage? message) async {
    if(message != null){
      Get.snackbar(message.notification!.title!, message.notification!.body!);
    }
  }
  initPushNotification()async{
   _firebaseMessaging.getInitialMessage().then(handleMessage);
   FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
}
