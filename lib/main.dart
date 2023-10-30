import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:todo_app/controller/camera_controller.dart';
import 'package:todo_app/controller/state_controller.dart';
import 'package:todo_app/page/home_widget.dart';
import 'package:todo_app/page/login_page.dart';
import 'package:todo_app/page/main_splash_screen.dart';
import 'package:todo_app/page/preview_todo.dart';
import 'package:todo_app/util/show_text.dart';
import 'package:todo_app/util/translation.dart';

import 'controller/requests_controller.dart';
import 'firebase_options.dart';

main() async {
  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    translations: TodoTranslations(),
    getPages: [
      GetPage(name: '/', page: () => const MainPage()),
      GetPage(name: '/login', page: () => const LoginPage()),
      GetPage(name: '/text', page: () => const ShowTextPage()),
      GetPage(name: '/home', page: () => const HomePage()),
      GetPage(name: '/preview/', page: () => const PreviewTodoPage()),
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
      child: MainSplashScreen(),
    );
  }
}
