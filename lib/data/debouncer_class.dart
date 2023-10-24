import 'dart:async';
import 'package:flutter/material.dart';
class Debouncer {
  Debouncer({required this.milliseconds});
  final int milliseconds;
  Timer? _timer;
  void run(VoidCallback action) {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class Throttler {
  Throttler({this.milliseconds = 100});
  final int milliseconds;
  int lastActionTime = 0;

  void run(VoidCallback action) {
    if (lastActionTime == 0) {
      action();
      lastActionTime = DateTime.now().millisecondsSinceEpoch;
    } else {
      if (DateTime.now().millisecondsSinceEpoch - lastActionTime > (milliseconds)) {
        action();
        lastActionTime = DateTime.now().millisecondsSinceEpoch;
      }
    }
  }
  reset(){
    lastActionTime = 0;
  }
}