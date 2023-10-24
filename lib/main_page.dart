import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:todo_app/controller/camera_controller.dart';
import 'package:todo_app/controller/state_controller.dart';
import 'package:todo_app/page/login_page.dart';
import 'package:todo_app/util/translation.dart';

import 'controller/requests_controller.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(TodoController());
  Get.put(CustomCameraController());
  Get.put(RequestsController()).dio.init();
  await Get.find<RequestsController>().init();
  runApp(GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: TodoTranslations(),
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
      home: const MainPage()));
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
