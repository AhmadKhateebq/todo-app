import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class DeepLinkHandler {
  final BuildContext context;
  final User? user;

  DeepLinkHandler({required this.context, required this.user});

  handle(String link) {
    if (link case '/') {
      if(user == null){
        _login();
      }else{
        _homeScreen();

      }
    } else if (link case '/login') {
      _login();
    } else {
      var uri = Uri.parse(link);
      var fragment = Uri.parse(uri.fragment);
      var queryParamaters = fragment.queryParameters;
      String route = fragment.pathSegments[0];
      if (route == 'preview') {
        if (queryParamaters['uid'] != null && queryParamaters['id'] != null) {
          if (user != null) {
            _previewLoggedIn(fragment.toString());
          }else{
            _previewVisitor(fragment.toString());
          }
        } else {
          if (user != null) {
            _homeScreen();
          }else{
            _login();
          }
        }
      }
    }
  }

  _homeScreen() => Navigator.pushNamed(context, '/home');

  _login() => Navigator.pushReplacementNamed(context, '/login');

  _previewVisitor(String link) {
      Navigator.pushReplacementNamed(context, '/login');
     Navigator.pushNamed(context, link);
  }
  _previewLoggedIn(String link) {
    Navigator.pushReplacementNamed(context, '/home');
    Navigator.pushNamed(context, link);
  }
}
