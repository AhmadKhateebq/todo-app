import 'dart:developer';
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geo_hash/geohash.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:todo_app/data/to_do_object.dart';
import 'package:todo_app/page/edit_page.dart';

import 'requests_controller.dart';

class TodoController extends GetxController with StateMixin {
  var darkMode = Get.isDarkMode.obs;
  final storage = GetStorage();

  var locale = Get.deviceLocale.obs;
  late FirebaseAnalytics analytics;
  var loading = true.obs;
  bool started = false;
  @override
  bool initialized = false;
  String long = '';
  String lat = '';
  String hash = '';
  var locationLoading = false.obs;

  restoreData() async {
    Get.changeTheme(
        storage.read("dark") == true ? ThemeData.dark() : ThemeData.light());
    try {
      Get.updateLocale(Locale(storage.read('locale')));
    } catch (e, s) {
      log(error: e, 'restoreData', stackTrace: s, name: 'ERROR');
    }
    Get.updateLocale(const Locale('en'));
  }

  void showAddTodoOverlay() {
    Get.to(
      () => ( AddAndEdit(edit: false, title: 'add todo', date: DateTime.now(),)),
    );
  }
  void showEditTodoOverlay(ToDo todo) {
    Get.to(
          () => (AddAndEdit(edit: true, title: 'Edit todo', date: todo.date,todo: todo,imageUrl: todo.imageUrl,todoName: todo.name,)),
    );
  }


  Future<RxBool> isLoading({bool withGoogle = false})  async {
    loading.value = true;
    if (!started) {
      started = true;
      await init();
    }
    return loading;
  }

  get darkIcon => darkMode.value ? Icons.light : Icons.light_outlined;

  get modeIcon => darkMode.value ? Icons.dark_mode : Icons.light_mode;

  get color => !darkMode.value ? Colors.deepPurple[600] : Colors.blueGrey;

  Future<void> changeTheme() async {
    logEvent("change_theme", {
      'from': darkMode.value ? "dark mode" : "light mode",
      'to': !darkMode.value ? "dark mode" : "light mode",
    });
    darkMode.value = !darkMode.value;
    await storage.write("dark", darkMode.value);
    storage.save();
    Get.changeTheme(Get.isDarkMode ? ThemeData.light() : ThemeData.dark());
  }

  changeLanguage(String? val) async {
    logEvent("changed_language", {
      'from': locale.value!.languageCode,
      'to': val!,
    });
    await storage.write("locale", val);
    storage.save();
    locale.value = Locale(val);
    Get.updateLocale(Locale(val));
  }

  logEvent([String? event, Map<String, dynamic>? parameters]) async {
    analytics = FirebaseAnalytics.instance;
    if(kIsWeb){
      return;
    }
    if (event != null && parameters != null) {
      await analytics.logEvent(name: event, parameters: parameters);
    } else if (event != null) {
      analytics.logEvent(name: event);
    } else {
      analytics.logEvent(name: "unknown_event");
    }
  }

  error() async {
    if (kDebugMode) {
      try {
        if (locale.value?.languageCode == ('ar')) {
          throw Exception();
        }
      } on FormatException catch (error, stackTrace) {
        FirebaseCrashlytics.instance.log("inside catch");
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'parser error',
          information: ['double parse a non number', 'more info'],
        );
        throw const FormatException();
      } on Exception catch (_) {
        throw Exception();
      }
    }
  }

  init() async {
    if (initialized) {
    } else {
      await Get.find<RequestsController>().init();
      await errorInit();
      await Future.delayed(const Duration(seconds: 1));
      await GetStorage.init();
      Get.find<TodoController>().change(RxStatus.success());
      analytics = FirebaseAnalytics.instance;
      initialized = true;
      try{
        if(!kIsWeb){
          await restoreData();
        }
      }catch (e){
      }
    }
    await Future.delayed(const Duration(seconds: 1));
    loading.value = false;
    print('loading = false');
    // await fillLogs();
  }

  errorInit() async {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      switch (error.toString()) {
        case 'FormatException':
          {
            break;
          }
        default:
          {
            FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
            break;
          }
      }
      return true;
    };
  }

  fillLogs() async {
    for (int i = 0; i < 50; i++) {
      // await analytics.logEvent(name : "list_tile_pressed");
      // await analytics.logEvent(name :"list_tile_pressed");
      // await analytics.logEvent(name :"drop_down_menu_selected");
      // await analytics.logEvent(name :"more_info_selected");
      // await analytics.logEvent(name :"error_occurred");
      // await analytics.logEvent(name :"changed_language", parameters: {
      //   'from': 'en',
      //   'to': 'ar',
      // });
      // await analytics.logEvent(name :"change_theme", parameters :
      //     {
      //   'from': "light mode",
      //   'to': "dark mode",
      // });

      await logEvent("item_deleted");
      await logEvent("item_deleted");
      await logEvent("item_deleted");
      await logEvent("item_deleted");
    }
  }

  getLocation() async {
    locationLoading.value = true;
    late PermissionStatus permissionStatus;
    if(await Permission.locationWhenInUse.isGranted){
      permissionStatus = PermissionStatus.granted;
    }else{
      permissionStatus = await Permission.locationWhenInUse.request();
    }
    if (permissionStatus.isGranted) {
      var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      log(position.longitude.toString(), name: "longitude");
      log(position.latitude.toString(), name: "latitude");
      MyGeoHash myGeoHash = MyGeoHash();
      hash = myGeoHash.geoHashForLocation(
          GeoPoint(position.latitude, position.longitude),
          precision: 7);
      lat = position.latitude.toString();
      long = position.longitude.toString();
      Get.snackbar("Hash : $hash", "longitude : $long "
          "Latitude : $lat");
    }else{
      log(permissionStatus.name,name: "permission");
      Get.snackbar("Location Permissions not granted", "we cannot access your location, "
          "so you wont be able to use any location based features");
    }
    locationLoading.value = false;
  }
}
