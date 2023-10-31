import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/controller/requests_controller.dart';
import 'package:todo_app/controller/state_controller.dart';
import 'package:todo_app/data/to_do_object.dart';
import 'package:todo_app/page/component/preview_body.dart';

class PageViewBody extends StatelessWidget {
  const PageViewBody({super.key, this.initialPage, this.fromDeepLink});
  final int? initialPage;
  final bool? fromDeepLink;
  @override
  Widget build(BuildContext context) {
    PageController controller = PageController(initialPage: initialPage??0);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Preview Your Todo\'s'),
        backgroundColor: Colors.deepPurple[600],
      ),
      body: PageView(
        allowImplicitScrolling: true,
        scrollDirection: Axis.horizontal,
        controller: controller,
        onPageChanged: (num) {
        },
        children: _list,
      ),
    );
  }

  List<PreviewBody> get _list {
    List<PreviewBody> todos = [];
    var list = Get.find<RequestsController>().filteredTodos.toList();
    for (ToDo value in list) {
      todos.add(PreviewBody(darkMode: Get.isDarkMode,
        todo: value,
        fromDeepLink: fromDeepLink??false,
      ));
    }
    return todos;
  }
}
