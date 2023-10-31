import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/controller/requests_controller.dart';
import 'package:todo_app/controller/state_controller.dart';
import 'package:todo_app/data/to_do_object.dart';
import 'package:todo_app/page/component/preview_body.dart';

import '../util/consts.dart';

class PreviewTodoPage extends StatefulWidget {
  const PreviewTodoPage({super.key});

  @override
  State<PreviewTodoPage> createState() => _PreviewTodoPageState();
}

class _PreviewTodoPageState extends State<PreviewTodoPage> {
  final controller = Get.find<TodoController>();
  ToDo todo = ToDo(
      date: DateTime.now(),
      name: 'Loading',
      imageUrl: loadingImage,
      done: false);
  bool fromDeepLink = false;

  @override
  void initState() {
    try {
      setIds();
      if (Get.arguments != null && Get.arguments['fromDeepLink'] != null) {
        fromDeepLink = Get.arguments['fromDeepLink'] as bool;
      }
    } catch (e) {
      log(e.toString());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(todo.name),
        backgroundColor: controller.color,
      ),
      body: PreviewBody(
        darkMode: Get.isDarkMode,
        todo: todo,
        fromDeepLink: fromDeepLink,
      ),
    ));
  }

  Future<void> getTodo(String uid, String id) async {
    try {
      (Get.find<RequestsController>().getTodo(uid, id))
          .then((value) => setState(() {
                todo = value;
              }));
    } catch (e) {
      todo = ToDo(
          date: DateTime.now(),
          name: 'no todo found',
          imageUrl: noImage,
          done: false);
    }
  }

  Future<void> setIds() async {
    // if (kIsWeb) {
    //   final initialURI = await getInitialUri();
    //   final idUri = Uri.parse(initialURI!.fragment);
    //   String uid = idUri.queryParameters['uid']!;
    //   String id = idUri.queryParameters['id']!;
    //   getTodo(uid, id);
    // } else {
    //   String uid = Get.parameters['uid']!;
    //   String id = Get.parameters['id']!;
    //   getTodo(uid, id);
    // }
    String uid = Get.parameters['uid']!;
    String id = Get.parameters['id']!;
    await getTodo(uid, id);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setIds();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    setIds();
  }
}
