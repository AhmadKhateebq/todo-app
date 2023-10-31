import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class DeepLinkHandler {
  final BuildContext _context;
  User? _user;
  DeepLinkHandler({required User? user,required BuildContext context}) : _user = user, _context = context;

  set user(User value) {
    _user = value;
  }
  updateUser(){
    _user = FirebaseAuth.instance.currentUser;
  }
  handle(String link) {
    if (link case '/') {
      if(_user == null){
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
          if (_user != null) {
            _previewLoggedIn(fragment.toString());
          }else{
            _previewVisitor(uri.toString());
          }
        } else {
          if (_user != null) {
            _homeScreen();
          }else{
            _login();
          }
        }
      }
    }
  }
  _homeScreen() => Navigator.pushReplacementNamed(_context, '/home');
  _login() => Navigator.pushReplacementNamed(_context, '/login');
  _previewVisitor(String link) {
      Navigator.pushReplacementNamed(
          _context,
          '/login',
          arguments: {
        'fromDeepLink':true,
        'link' : link
      });
  }
  _previewLoggedIn(String link) {
    Navigator.pushReplacementNamed(_context, link);
  }
}
