import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:todo_app/controller/camera_controller.dart';
import 'package:todo_app/controller/state_controller.dart';
import 'package:todo_app/page/home_widget.dart';
import 'package:todo_app/page/login_page.dart';
import 'package:todo_app/page/preview_todo.dart';
import 'package:todo_app/util/translation.dart';

import 'controller/requests_controller.dart';
import 'firebase_options.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(TodoController());
  Get.put(CustomCameraController());
  Get.put(RequestsController()).dio.init();

  await Get.find<RequestsController>().init();
  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    translations: TodoTranslations(),
    getPages: [
      GetPage(name: '/', page: () => const MainPage()),
      GetPage(name: '/home', page: () => const HomePage()),
      GetPage(name: '/preview/:uid/:id', page: () => const PreviewTodoPage()),
    ],
    supportedLocales: const [
      Locale('ar'),
      Locale('en'),
    ],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    locale: Get.deviceLocale,
    fallbackLocale: const Locale('en'),
    initialRoute: '/',
  ));
  // runApp(const MainPage());
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: LoginPage(),
    );
  }
}
