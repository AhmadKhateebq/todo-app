import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:todo_app/controller/requests_controller.dart';
import 'package:todo_app/controller/state_controller.dart';
import 'package:todo_app/page/home_widget.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('splash');
    return Obx(() => Get.find<TodoController>().loading.value
        ? loadingScreen()
        : const HomePage());
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
