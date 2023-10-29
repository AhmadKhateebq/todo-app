import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    print(
      'splash'
    );
    return const Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: Stack(alignment: Alignment.center, children: [
          LoadingIndicator(
            indicatorType: Indicator.ballScale,
            colors: [Colors.deepPurple,Colors.deepOrangeAccent],
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
}
