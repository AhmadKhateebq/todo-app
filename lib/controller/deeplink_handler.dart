import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/controller/requests_controller.dart';
import 'package:todo_app/page/component/page_view_comp.dart';

class DeepLinkHandler {
  final BuildContext _context;
  User? _user;

  DeepLinkHandler({required User? user, required BuildContext context})
      : _user = user,
        _context = context;

  set user(User value) {
    _user = value;
  }

  updateUser() {
    _user = FirebaseAuth.instance.currentUser;
  }

  handle(String link) {
    if (link case '/') {
      if (_user == null) {
        _login();
      } else {
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
          var uid = (_user!.uid);
          if (_user != null) {
            if (uid == queryParamaters['uid']) {
              _previewOwner(queryParamaters['id']!);
            } else {
              _previewLoggedIn(fragment.toString());
            }
          } else {
            _previewVisitor(uri.toString());
          }
        } else {
          if (_user != null) {
            _homeScreen();
          } else {
            _login();
          }
        }
      }
    }
  }

  _homeScreen() => Navigator.pushReplacementNamed(_context, '/home');

  _login() => Navigator.pushReplacementNamed(_context, '/login');

  _previewVisitor(String link) {
    Navigator.pushReplacementNamed(_context, '/login',
        arguments: {'fromDeepLink': true, 'link': link});
  }

  _previewLoggedIn(String link) {
    Navigator.pushReplacementNamed(_context, link, arguments: {
      'fromDeepLink': true,
    });
  }

  _previewOwner(String id) {
    int index = _getIndex(id);
    Navigator.pushReplacement(_context,
        MaterialPageRoute(builder: (context) => PageViewBody(initialPage: index,fromDeepLink: true,)));
  }

  int _getIndex(String id) {
    try {
      return Get.find<RequestsController>()
          .filteredTodos
          .toList()
          .map((e) => e.id!)
          .toList()
          .indexOf(id);
    } catch (e) {
      return 0;
    }
  }
}
