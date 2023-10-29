import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'consts.dart';

class LoginInterceptor extends Interceptor {
  static var _token = "";

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log(options.uri.toString(), name: "URL");
    log(_token, name: "token");
    options.headers.forEach((key, value) {
      log(value.toString(), name: key.toString());
    });
    options.queryParameters.forEach((key, value) {
      log(value.toString(), name: key.toString());
    });
    FirebaseAnalytics.instance.logEvent(
        name: "api_request",
        parameters: {"url": options.path});
    if (options.path == "${loginUrl}signInWithPassword" ||
        options.path == "${loginUrl}signUp") {
      options.queryParameters.addAll({
        "key": key,
      });
    } else {
      options.queryParameters.addAll({"auth": _token});
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data["idToken"] != null) {
      _token = response.data["idToken"];
    }
    super.onResponse(response, handler);
  }

  static void setToken(String token) {
    _token = token;
  }

  static void logout() {
    _token = "";
  }
}
