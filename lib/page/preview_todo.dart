import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/controller/requests_controller.dart';
import 'package:todo_app/controller/state_controller.dart';
import 'package:todo_app/data/to_do_object.dart';
import 'package:todo_app/page/home_widget.dart';

class PreviewTodoPage extends StatefulWidget {
  const PreviewTodoPage({super.key});

  @override
  State<PreviewTodoPage> createState() => _PreviewTodoPageState();
}

class _PreviewTodoPageState extends State<PreviewTodoPage> {
  late final ToDo todo;
  var isLoading = true.obs;
  @override
  void initState() {
    String uid = Get.parameters['uid']!;
    String id = Get.parameters['id']!;
    print(uid);
    print(id);
    getTodo(uid,id);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TodoController>();
    return SafeArea(
      child: Obx(()=>isLoading.value?const Center(child: CircularProgressIndicator()):Scaffold(
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
                            Get.back();
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
      )),
    );
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
    todo = await Get.find<RequestsController>().getTodo(uid, id);
    isLoading.value = false;
  }
}
