import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:todo_app/controller/deeplink_handler.dart';
import 'package:todo_app/controller/state_controller.dart';
import 'package:todo_app/firebase_options.dart';

import '../controller/camera_controller.dart';
import '../controller/requests_controller.dart';

class MainSplashScreen extends StatefulWidget {
  const MainSplashScreen({super.key});

  @override
  State<MainSplashScreen> createState() => _MainSplashScreenState();
}

class _MainSplashScreenState extends State<MainSplashScreen> {
  @override
  void initState() {
    handle();
    super.initState();
  }

  handle() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    Get.put(TodoController(),permanent: true);
    Get.put(CustomCameraController(),permanent: true);
    Get.put(RequestsController(),permanent: true);
    await Get.find<RequestsController>().init();
    var todoController = Get.find<TodoController>();
    var requests = Get.find<RequestsController>();
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await requests.signInAgain(FirebaseAuth.instance.currentUser!);
    }
    var currentRoute = Get.currentRoute;
    if (context.mounted) {
      var handler = DeepLinkHandler(context: context,user:user);
      handler.handle(currentRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return loadingScreen();
  }

  loadingScreen() => const Scaffold(
        backgroundColor: Colors.blueGrey,
        body: Center(
          child: Stack(alignment: Alignment.center, children: [
            LoadingIndicator(
              indicatorType: Indicator.ballScale,
              colors: [Colors.deepPurple, Colors.deepOrangeAccent],
            ),
            Text(
              "Loading",
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Colors.white),
            )
          ]),
        ),
      );
}
