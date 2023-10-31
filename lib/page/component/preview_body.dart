import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/data/to_do_object.dart';

import '../../controller/state_controller.dart';

class PreviewBody extends StatelessWidget {
  const PreviewBody({super.key, required this.darkMode, required this.todo, required this.fromDeepLink});
  final bool darkMode;
  final ToDo todo;
  final bool fromDeepLink;
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TodoController>();
    return Container(
      padding: const EdgeInsets.all(20),
      color: darkMode ? Colors.black87 : Colors.white70,
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
                      onPressed: backOnAction,
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

  backOnAction() {
    if (fromDeepLink) {
      if (Get.context!.mounted) {
        Navigator.pushReplacementNamed(Get.context!, '/home');
      }
    } else {
      print('else');
      Get.back();
    }
  }
}
