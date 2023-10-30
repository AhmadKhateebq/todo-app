import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/controller/requests_controller.dart';
import 'package:todo_app/controller/state_controller.dart';
import 'package:todo_app/data/to_do_object.dart';
import 'package:todo_app/page/login_page.dart';
import 'package:uni_links/uni_links.dart';

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

  @override
  void initState() {
    try {
      setIds();
    } catch (e) {
      log(e.toString());
    }
    super.initState();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    setIds();
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
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: getText(todo.name),
        backgroundColor: controller.color,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        color: Get.isDarkMode ? Colors.black87 : Colors.white70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
                height: 250,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(todo.imageUrl!),
                )),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  getText('Name : ${todo.name}'),
                  getText(
                      '${'Date'.tr} : ${DateFormat('dd MMMM y').format(todo.date)}'),
                  getText('Status : ${todo.done! ? 'Done' : 'Not Finished'}'),
                  getText(getDueOrNot()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          try{
                            Get.back();
                          }catch (e,s){
                            print(e.toString());
                            print(s.toString());
                          }

                        },
                        child: getText('Back'),
                      ),
                      TextButton(
                        onPressed: () {
                          controller.showEditTodoOverlay(todo);
                        },
                        child: getText('Edit'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Text getText(String text) {
    return Text(text);
  }

  String getDueOrNot() {
    if (todo.done ?? false) {
      return '';
    }
    int years;
    int months;
    int days;
    var today = DateTime.now();
    if (todo.date.isBefore(today)) {
      years = today.year - todo.date.year;
      months = today.month - todo.date.month;
      days = today.day - todo.date.day;
      if (years + months + days == 0) {
        return 'today is the day';
      }
      return 'Its ${years > 0 ? ' $years years' : ''}${months > 0 ? ' $months months' : ''}${days > 0 ? ' $days days' : ''} Late';
    } else {
      years = todo.date.year - today.year;
      months = todo.date.month - today.month;
      days = todo.date.day - today.day;
      return 'There Are ${years > 0 ? ' $years years ' : ''}${months > 0 ? ' $months months ' : ''}${days > 0 ? ' $days days' : ''} Left';
    }
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setIds();
  }
}
