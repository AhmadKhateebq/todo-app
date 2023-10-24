import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:image_picker/image_picker.dart';

import '../../firebase_options.dart';
import '../data/to_do_object.dart';
import '../page/login_page.dart';
import '../util/login_interceptor.dart';
import 'dio_controller.dart';
import 'firebase_controller.dart';
import 'state_controller.dart';

class RequestsController extends GetxController{
  final DioRequests dio = DioRequests.instance;
  var filteredTodos = <ToDo>[].obs;
  RxBool isLoading = true.obs;
  Map<String, dynamic> _userCredential = {};
  static String finalSearch = "";
  late List<ToDo> latest;
  static int i = 0;
  var token = CancelToken();
  bool finished = false;
  int anchor = -1;
  var pageLock = false.obs;
  var pageEnd = false.obs;
  List<ToDo> data = [];
  Future<void>? _initialization;
  GoogleSignInUserData? _currentUser;

  init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAppCheck.instance
        .activate(androidProvider: AndroidProvider.playIntegrity);
    final storage = FirebaseStorage.instance.ref().child("images");
    if(kDebugMode){
      print(storage.fullPath);
    }
    await FirebaseNotificationController.getRef().init();
  }

  Future<String> getImageFromGallery() async {
    try{
      ImagePicker imagePicker = ImagePicker();
      XFile? file = (await imagePicker.pickImage(source: ImageSource.gallery))!;
      return await uploadImage(file);
    }catch(e){
      if (kDebugMode) {
        print("D:");
      }
      return "https://upload.wikimedia.org/wikipedia/commons/1/14/No_Image_Available.jpg";
    }

  }
  Future<String> getImageFromCamera() async {
    try{
      ImagePicker imagePicker = ImagePicker();
      XFile? file = (await imagePicker.pickImage(source: ImageSource.camera))!;
      return await uploadImage(file);
    }catch(e){
      if (kDebugMode) {
        print("D:");
      }
      return "https://upload.wikimedia.org/wikipedia/commons/1/14/No_Image_Available.jpg";
    }
  }
  Future<String>uploadImage(XFile file) async {
    Reference referenceRoot = FirebaseStorage.instance.ref();
    //use user uid as subfolder
    Reference referenceDirImages =
    referenceRoot.child('images/${_userCredential['localId']}/');
    Reference referenceImageToUpload = referenceDirImages.child(file.name);
    try {
      await referenceImageToUpload.putFile(File(file.path));
      var imageUrl = await referenceImageToUpload.getDownloadURL();
      if (kDebugMode) {
        print(imageUrl);
      }
      return imageUrl;
    } catch (error) {
      log(error:error,'upload image',name: 'ERROR');
      rethrow;
    }
  }

  fetchAllData() {
    if (filteredTodos.isEmpty) {
      filteredTodos.value = dio.fetchAll();
    }
    return filteredTodos;
  }

  printBy({bool? reset = false}) async {
    pageLock.value = true;
    int entries = 10;
    await fetchDataByPage(entries: entries, anchorCID: anchor, reset: reset);
    data = filteredTodos;
    pageLock.value = false;
  }

  empty() async {
    pageLock.value = true;
    filteredTodos.value = [];
    data = filteredTodos;
    pageEnd.value = false;
    anchor = -1;
    await printBy(reset: true);
    pageLock.value = false;
  }

  emptyAfterSearch() async {
    pageLock.value = true;
    filteredTodos.value = data;
    pageLock.value = false;
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _userCredential = await dio.loginAndRegister(
          email: email, password: password, register: false);
      // print(_userCredential.toString());
      await printBy();
      return true;
    } catch (e) {
      log(error:e,'sign in',name: 'ERROR');
      rethrow;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      _userCredential = await dio.loginAndRegister(
          email: email, password: password, register: true);
      await printBy();
      return true;
    } catch (e) {
      log(error:e,'register',name: 'ERROR');
      // rethrow;
      return false;
    }
  }

  Future<List<ToDo>> search(String value) async {
    if (value == "" || value.isEmpty) {
      filteredTodos.value = data;
    }
    if (value == finalSearch) {
      return latest;
    }
    token.cancel("cancelled");
    token = CancelToken();
    finished = false;
    try {
      final response = await dio.search(
          localId: _userCredential['localId'],
          value: value,
          cancelToken: token);
      if (finished) {
        token.cancel("cancelled");
        return [];
      }
      finished = true;
      final Map<String, dynamic> map = jsonDecode(response.toString());
      finalSearch = value;
      List<ToDo> results = [];
      map.forEach((key, value) {
        results.add(ToDo(
            date: DateTime.parse(value['date']),
            name: value['name'],
            id: key,
            cid: value['cid']));
      });
      latest = results;
      filteredTodos.value = results;
      return results;
    } on DioException catch (e) {
      log(error:e,'search',name: 'ERROR');
      return [];
    }
  }

  fetchDataByPage(
      {int? anchorCID, required int entries, bool? reset = false}) async {
    try {
      final response = await dio.fetchFiltered(
          localId: _userCredential['localId'],
          entries: entries,
          anchorCID: anchorCID);
      try {
        if (reset!) {
          List<ToDo> resetData = List.of(data);
          final Map<String, dynamic> map = jsonDecode(response.toString());
          map.forEach((key, value) {
            if (value["cid"] != -9) {
              ToDo todo = ToDo.fromJson(key, value);
              resetData.add(todo);
            }
          });
          data = resetData;
          anchor = resetData.last.cid!;
          filteredTodos.value = resetData;
          return true;
        } else {
          final Map<String, dynamic> map = jsonDecode(response.toString());
          map.forEach((key, value) {
            if (value["cid"] != -9) {
              ToDo todo = ToDo.fromJson(key, value);
              filteredTodos.add(todo);
            }
          });
          data = filteredTodos;
          anchor = filteredTodos.last.cid!;
          if (filteredTodos.length < 10) {
            pageEnd.value = true;
          }
          return true;
        }
      } catch (e,s) {
        log(error:e,'fetch data by page',stackTrace: s,name: 'ERROR');
        pageEnd.value = true;
        return 0;
      }
    } on DioException {
      // await dio.postQuery(
      //    localId: _userCredential['localId'],
      //    entries: entries,
      //    anchorCID: anchorCID);
    }
  }

  Future<String> addTodo(ToDo toDo) async {
    return await dio.addTodo(
      localId: _userCredential['localId'],
      toDo: toDo,
    );
  }

  Future<void> delete(ToDo todo) async {
    var response =
        await dio.deleteTodo(localId: _userCredential['localId'], todo: todo);
    empty();
    log(response.data.toString());
  }

  bool validatePassword(String password) {
    if (password.length >= 8) {
      return true;
    } else {
      return false;
    }
  }

  bool validatePasswordEmail(String password, String email) {
    if (password.isEmpty && !validateEmail(email)) {
      return true;
    } else {
      return validatePassword(password);
    }
  }

  bool validateEmail(String email) {
    return RegExp(r'^.+@[a-zA-Z]+\.[a-zA-Z]+(\.?[a-zA-Z]+)$').hasMatch(email);
  }

  Future<void> logout() async {
    LoginInterceptor.logout();
    dio.removeGoogleLogIn();
    filteredTodos.value = [];
    _userCredential = {};
    if (await GoogleSignIn().isSignedIn()) {
      await GoogleSignIn().signOut();
    }
    Get.find<TodoController>().loading.value = true;
    Get.find<TodoController>().started = false;
    anchor = -1;
    Get.offAll(() => const LoginPage());
  }

  void cancelRequest() {
    token.cancel("cancelled");
    token = CancelToken();
  }

  Future<bool> handleSignIn() async {
    try {
      await _ensureInitialized();
      _currentUser = (await GoogleSignInPlatform.instance.signIn());
      // var response =
      await _getAuthHeaders();
      // _userCredential.addAll({'localId': _currentUser!.id});
      await printBy();
      return true;
    } catch (error) {
      final bool canceled =
          error is PlatformException && error.code == 'sign_in_canceled';
      if (!canceled) {
        if (kDebugMode) {
          print(error);
        }
      }
      return false;
    }
  }

  Future<GoogleSignInTokenData> _getAuthHeaders() async {
    final GoogleSignInUserData? user = _currentUser;
    if (user == null) {
      throw StateError('No user signed in');
    }
    final GoogleSignInTokenData response =
        await GoogleSignInPlatform.instance.getTokens(
      email: user.email,
      shouldRecoverAuth: true,
    );
    if (kDebugMode) {
      var a = await FirebaseAuth.instance.signInWithCredential(AuthCredential(
          providerId: 'google.com',
          signInMethod: 'google.com',
          accessToken: response.accessToken));
      String token = (await (a.user!.getIdToken()))!;
      await dio.setGoogleLogIn(token);
      // await dio.setGoogleLogIn(response.accessToken!);
      _userCredential.addAll({'localId': a.user!.uid});
    }

    return response;
  }

  Future<void> _ensureInitialized() {
    return _initialization ??=
        GoogleSignInPlatform.instance.initWithParams(const SignInInitParameters(
      scopes: <String>[
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    ))
          ..catchError((dynamic _) {
            _initialization = null;
          });
  }
}
