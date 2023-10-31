import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as m;

import 'package:dio/dio.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_app/page/splash.dart';
import 'package:todo_app/util/consts.dart';

import '../data/to_do_object.dart';
import '../page/login_page.dart';
import '../util/login_interceptor.dart';
import 'dio_controller.dart';
import 'firebase_controller.dart';
import 'state_controller.dart';

class RequestsController extends GetxController {
  final DioRequests dio = DioRequests.instance;
  var filteredTodos = <ToDo>[].obs;
  RxBool isLoading = true.obs;
  Map<String, dynamic> userCredential = {};
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
  var databaseInit = false;
  late DatabaseReference database;
  var filters = {
    'all': true,
    'deleted': false,
    'expired': false,
    'done': false,
    'not finished': false,
  };

  init() async {
    if (!kIsWeb) {
      await FirebaseAppCheck.instance
          .activate(androidProvider: AndroidProvider.playIntegrity);
      await FirebaseNotificationController.getRef().init();
    } else {}
    final storage = FirebaseStorage.instance.ref().child("images");
    if (!kIsWeb) {
      FirebaseDatabase.instance.setPersistenceEnabled(true);
    }
  }

  bool getFilterSet(String filter) {
    return filters[filter.toLowerCase()] ?? false;
  }

  Future<ToDo> getTodo(String userId, String todoId) async {
    final response =
        await FirebaseDatabase.instance.ref('/todo/$userId/$todoId').get();
    return ToDo.fromDynamicMap(key, response.value as Map<dynamic, dynamic>);
  }

  Future<String> getImageFromGallery() async {
    try {
      ImagePicker imagePicker = ImagePicker();
      XFile? file = (await imagePicker.pickImage(source: ImageSource.gallery))!;
      return await uploadImage(file);
    } catch (e) {

      return noImage;
    }
  }

  Future<String> getImageFromCamera() async {
    try {
      ImagePicker imagePicker = ImagePicker();
      XFile? file = (await imagePicker.pickImage(source: ImageSource.camera))!;
      return await uploadImage(file);
    } catch (e) {
      return noImage;
    }
  }

  Future<String> uploadImage(XFile file) async {
    Reference referenceRoot = FirebaseStorage.instance.ref();
    //use user uid as subfolder
    Reference referenceDirImages =
        referenceRoot.child('images/${userCredential['localId']}/');
    Reference referenceImageToUpload =
        referenceDirImages.child("${file.name}-${m.Random().nextInt(1000)}");
    try {
      if (kIsWeb) {
        var data = await file.readAsBytes();
        final newMetadata = SettableMetadata(
          contentType: file.mimeType!,
        );
        await referenceImageToUpload.putData(data, newMetadata);
      } else {
        await referenceImageToUpload.putFile(File(file.path));
      }

      var imageUrl = await referenceImageToUpload.getDownloadURL();
      return imageUrl;
    } catch (error) {
      log(error: error, 'upload image', name: 'ERROR');
      rethrow;
    }
  }

  getDeletedData() async {
    List<ToDo> entries =
        await database.orderByChild('cid').equalTo(-9).get().then((value) {
      try {
        return (value.value as Map<dynamic, dynamic>)
            .entries
            .map((e) => ToDo.fromDynamicMap(
                e.key.toString(), (e.value as Map<dynamic, dynamic>)))
            // .where((element) => element.date.isBefore(DateTime.now()))
            .toList();
      } catch (e) {
        log('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
        return [];
      }
    });
    filteredTodos.value = entries;
  }

  getDueData() async {
    List<ToDo> entries =
        await database.orderByChild('cid').startAfter(-9).get().then((value) {
      return (value.value as Map<dynamic, dynamic>)
          .entries
          .map((e) => ToDo.fromDynamicMap(
              e.key.toString(), (e.value as Map<dynamic, dynamic>)))
          .where((element) => element.date.isBefore(DateTime.now()))
          .where((element) => !(element.done ?? true))
          .toList();
    });
    filteredTodos.value = entries;
  }

  getNotDueData() async {
    List<ToDo> entries =
        await database.orderByChild('cid').startAfter(-9).get().then((value) {
      return (value.value as Map<dynamic, dynamic>)
          .entries
          .map((e) => ToDo.fromDynamicMap(
              e.key.toString(), (e.value as Map<dynamic, dynamic>)))
          .where((element) => element.date.isAfter(DateTime.now()))
          .where((element) => !(element.done ?? true))
          .toList();
    });
    filteredTodos.value = entries;
  }

  getDoneData() async {
    List<ToDo> entries =
        await database.orderByChild('cid').startAfter(-9).get().then((value) {
      return (value.value as Map<dynamic, dynamic>)
          .entries
          .map((e) => ToDo.fromDynamicMap(
              e.key.toString(), (e.value as Map<dynamic, dynamic>)))
          .where((element) => (element.done ?? true))
          .toList();
    });
    filteredTodos.value = entries;
  }

  fetchAnchoredData({bool? reset = false}) async {
    if (!databaseInit) {
      database =
          FirebaseDatabase.instance.ref('todo/${userCredential['localId']}');
    }
    pageLock.value = true;
    int entries = 10;
    await fetchDataByPage(entries: entries, anchorCID: anchor, reset: reset);
    data = filteredTodos.toList();
    pageLock.value = false;
  }

  empty() async {
    pageEnd.value = false;
    anchor = -1;
    await fetchAnchoredData(reset: true);
  }

  emptyAfterSearch() async {
    pageLock.value = true;
    filteredTodos.value = data;
    pageLock.value = false;
  }
  Future<bool> signInAgain(User user) async {
    try {
      userCredential['localId'] = user.uid;
      await empty();
      return true;
    } catch (e) {
      log(error: e, 'sign in', name: 'ERROR');
      rethrow;
    }
  }

  Future<bool> signIn(String email, String password) async {
    await logout(login: true);
    try {
      var a = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      userCredential['localId'] = a.user!.uid;
      await empty();
      return true;
    } catch (e) {
      log(error: e, 'sign in', name: 'ERROR');
      rethrow;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      var a = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      userCredential['localId'] = a.user!.uid;
      await fetchAnchoredData();
      return true;
    } catch (e) {
      log(error: e, 'register', name: 'ERROR');
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
          localId: userCredential['localId'], value: value, cancelToken: token);
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
      log(error: e, 'search', name: 'ERROR');
      return [];
    }
  }

  changeFilters(String filter) {
    filter = filter.toLowerCase();
    if (filter == 'all') {
      filters.updateAll((key, value) => key == 'all' ? true : false);
      empty();
    } else if (filter == 'deleted') {
      filters.updateAll((key, value) => key == 'deleted' ? true : false);
      getDeletedData();
    } else if (filter == 'expired') {
      filters.updateAll((key, value) => key == 'expired' ? true : false);
      getDueData();
    } else if (filter == 'not finished') {
      filters.updateAll((key, value) => key == 'not finished' ? true : false);
      getNotDueData();
    } else if (filter == 'done') {
      filters.updateAll((key, value) => key == 'done' ? true : false);
      getDoneData();
    }
  }

  fetchDataByPage(
      {int? anchorCID, required int entries, bool? reset = false}) async {
    List<ToDo> newData = await database
        .orderByChild('cid')
        .startAfter(anchorCID)
        .limitToFirst(entries)
        .get()
        .then((value) {
      try {
        return (value.value as Map<dynamic, dynamic>)
            .entries
            .map((e) => ToDo.fromDynamicMap(
                e.key.toString(), (e.value as Map<dynamic, dynamic>)))
            .toList();
      } catch (e, s) {
        log(error: e, stackTrace: s, 'error');
        return [];
      }
    });
    try {
      if (reset!) {
        filteredTodos.value = newData;
        data = newData;
      } else {
        filteredTodos.addAll(newData);
        data.addAll(newData);
      }
      anchor = filteredTodos.last.cid!;
      if (filteredTodos.length < 10) {
        pageEnd.value = true;
      }
    } catch (e) {
      filteredTodos.value = [];
      data = [];
      anchor = 0;
      pageEnd.value = true;
    }
  }

  Stream<DatabaseEvent> fetchDataByPageStream(
      {int? anchorCID, required int entries, bool? reset = false}) {
    return database.onValue;
  }

  @Deprecated('use fetchDataByPage instead')
  fetchDataByPageDio(
      {int? anchorCID, required int entries, bool? reset = false}) async {
    try {
      final response = await dio.fetchFiltered(
          localId: userCredential['localId'],
          entries: entries,
          anchorCID: anchorCID);
      try {
        // getDueData();
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
          if (filteredTodos.length < 10) {
            pageEnd.value = true;
          }
          return true;
        } else {
          final Map<String, dynamic> map = jsonDecode(response.toString());
          map.forEach((key, value) {
            if (value["cid"] != -9) {
              ToDo todo = ToDo.fromJson(key, value);
              filteredTodos.add(todo);
            }
          });
          data = filteredTodos.toList();
          anchor = filteredTodos.last.cid!;
          if (filteredTodos.length < 10) {
            pageEnd.value = true;
          }
          return true;
        }
      } catch (e, s) {
        log(error: e, 'fetch data by page', stackTrace: s, name: 'ERROR');
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

  addTodo(ToDo toDo) async {
    String id = database.push().key!;
    toDo.id = id;
    int c = await counter;
    toDo.cid = c;
    await database.push().set(toDo.toJson());
    empty();
  }

  editTodo(ToDo toDo) async {
    await database.update(toDo.toJson());
    empty();
  }

  Future<void> delete(ToDo todo) async {
    // var response =
    //     await dio.deleteTodo(localId: _userCredential['localId'], todo: todo);
    await database.child(todo.id!).update({'cid': -9});
    empty();
  }

  Future<void> deleteForever(ToDo todo) async {
    // var response =
    //     await dio.deleteTodo(localId: _userCredential['localId'], todo: todo);
    await database.child(todo.id!).remove();
    getDeletedData();
  }

  done(ToDo todo) async {
    await database.child(todo.id!).update({'done': true});
    empty();
  }

  Future<void> restore(ToDo todo) async {
    if (todo.cid != -9) {
      return;
    }
    int c = await counter;
    await database.child(todo.id!).update({'cid': c});
    getDeletedData();
  }

  Future<int> get counter async {
    int counter = (((await FirebaseDatabase.instance.ref('counter').get())
        .value) as Map<dynamic, dynamic>)['counter']!;
    await FirebaseDatabase.instance
        .ref('counter')
        .update({'counter': counter + 1});
    return counter;
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

  Future<void> logout({bool? login}) async {
    LoginInterceptor.logout();
    dio.removeGoogleLogIn();
    FirebaseAuth.instance.signOut();
    filteredTodos.value = [];
    userCredential = {};
    if (await GoogleSignIn().isSignedIn()) {
      await GoogleSignIn().signOut();
    }
    Get.find<TodoController>().loading.value = true;
    Get.find<TodoController>().started = false;
    anchor = -1;
    if(login??false){
      Get.to(()=>const SplashScreen());
    }else{
      Get.offAll(() => const LoginPage());
    }

  }

  void cancelRequest() {
    token.cancel("cancelled");
    token = CancelToken();
  }

  Future<bool> signInWithGoogleWeb() async {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();
    googleProvider
        .addScope('https://www.googleapis.com/auth/contacts.readonly');
    googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

    // Once signed in, return the UserCredential
    // var creds =
    await FirebaseAuth.instance.signInWithPopup(googleProvider);
    // Or use signInWithRedirect
    // return await FirebaseAuth.instance.signInWithRedirect(googleProvider);
    return true;
  }

  Future<bool> handleSignInWeb() async {
    try {
      await _ensureInitialized();
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider
          .addScope('https://www.googleapis.com/auth/contacts.readonly');
      googleProvider.setCustomParameters({'login_hint': 'user@example.com'});
      // Once signed in, return the UserCredential
      var creds = await FirebaseAuth.instance.signInWithPopup(googleProvider);
      var uid = creds.user!.uid;
      var idToken = await creds.user!.getIdToken();
      // var accessToken = creds.credential!.accessToken!;
      await dio.setGoogleLogIn(idToken!);
      // await dio.setGoogleLogIn(response.accessToken!);
      userCredential.addAll({'localId': uid});
      // _userCredential.addAll({'localId': _currentUser!.id});
      await fetchAnchoredData();
      return true;
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> handleSignInAndroid() async {
    try {
      await _ensureInitialized();
      _currentUser = (await GoogleSignInPlatform.instance.signIn());
      print(_currentUser);
      // var response =
      await _getAuthHeaders();
      // _userCredential.addAll({'localId': _currentUser!.id});
      await fetchAnchoredData();
      return true;
    } catch (error) {
      return false;
      // rethrow;
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
    var a = await FirebaseAuth.instance.signInWithCredential(AuthCredential(
        providerId: 'google.com',
        signInMethod: 'google.com',
        accessToken: response.accessToken));
    await FirebaseAuth.instance
        .signInWithCredential(GoogleAuthProvider.credential(
      idToken: _currentUser!.idToken,
      accessToken: response.accessToken,
    ));
    await dio.setGoogleLogIn(_currentUser!.idToken!);
    // await dio.setGoogleLogIn(response.accessToken!);
    userCredential.addAll({'localId': a.user!.uid});

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
