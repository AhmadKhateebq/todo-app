import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/controller/state_controller.dart';
import 'package:todo_app/data/to_do_object.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../controller/requests_controller.dart';
import '../../data/debouncer_class.dart';

class ListViewBody extends StatefulWidget {
  const ListViewBody({super.key, required this.locale});

  final String locale;

  @override
  State<ListViewBody> createState() => _ListViewBodyState();

  static const Map<String, String> arabicDigits = <String, String>{
    '0': '\u0660',
    '1': '\u0661',
    '2': '\u0662',
    '3': '\u0663',
    '4': '\u0664',
    '5': '\u0665',
    '6': '\u0666',
    '7': '\u0667',
    '8': '\u0668',
    '9': '\u0669',
  };
  static const Map<String, String> englishDigits = <String, String>{
    '\u0660': '0',
    '\u0661': '1',
    '\u0662': '2',
    '\u0663': '3',
    '\u0664': '4',
    '\u0665': '5',
    '\u0666': '6',
    '\u0667': '7',
    '\u0668': '8',
    '\u0669': '9',
  };
}

class _ListViewBodyState extends State<ListViewBody> {
  final debouncer = Debouncer(milliseconds: 300);
  bool search = false;

  @override
  void dispose() {
    super.dispose();
    Get.find<RequestsController>().cancelRequest();
  }

  @override
  Widget build(BuildContext context) {
    List<ToDo> list = Get.find<RequestsController>().filteredTodos;
    final searchController = TextEditingController();
    // final textFieldKey = GlobalKey<EditableTextState>();
    Get.find<TodoController>().logEvent("main_screen_entered");
    return Obx(() => Column(
          children: [
            TextField(
              // key: textFieldKey,
              decoration: const InputDecoration(
                floatingLabelStyle: TextStyle(color: Colors.deepPurple),
                // border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyan),
                ),
                labelText: "search",
                labelStyle: TextStyle(color: Colors.black87),
              ),
              controller: searchController,
              onChanged: (val) {
                debouncer.run(() async {
                  search = true;
                  if (val == "" || val.isEmpty) {
                    await Get.find<RequestsController>().empty();
                    search = false;
                  } else {
                    var results =
                        await Get.find<RequestsController>().search(val);
                    if (results != []) {
                      log(results.toString(), name: "SEARCH RESULTS");
                    } else {
                      searchController.text = "couldnt find";
                      log("COULDNT FIND ANY", name: "SEARCH RESULTS");
                    }
                  }
                });
              },
            ),
            Expanded(
              child: ListView.builder(
                  controller: scrollController,
                  itemCount: list.length + 1,
                  itemBuilder: (context, index) {
                    return (index != list.length)
                        ? tileMaker(index, list[index])
                        : getLoadingTile();
                  }),
            ),
          ],
        ));
  }

  final _scrollController = ScrollController();

  Widget tileMaker(int index, ToDo todo) {
    return Card(
      child: ListTile(
        trailing: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            image: DecorationImage(
              image:
                   NetworkImage(todo.imageUrl!,scale: .1),
              fit: BoxFit.cover,
            ),
          ),
          // child: Image.network(todo.imageUrl!),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
          onPressed: () async {
            Get.find<TodoController>().logEvent("item_deleted", {'index': index});
            await Get.find<RequestsController>().delete(todo);
            // list.removeAt(index);
          },
        ),
        title: Text(parsNumbers(todo.name, (widget.locale))),
        subtitle: Text(DateFormat.yMMMd(widget.locale).format(todo.date)),
      ),
    );
  }

  void _setupScrollController() {
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _scrollListener() async {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent) {
      if (search) {
        await Get.find<RequestsController>().empty();
        _scrollController.animateTo(_scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn);
        search = false;
      } else {
        if (!Get.find<RequestsController>().pageLock.value) {
          await Get.find<RequestsController>().printBy();
          await _scrollController.animateTo(
              _scrollController.position.maxScrollExtent - 50,
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn);
        }
      }

      if (Get.find<RequestsController>().pageEnd.value) {
        await _scrollController.animateTo(
            _scrollController.position.maxScrollExtent - 70,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.fastOutSlowIn);
      }
    }
  }

  ScrollController get scrollController {
    _setupScrollController();
    return _scrollController;
  }

  getLoadingTile() {
    return Shimmer.fromColors(
      baseColor: Colors.black26,
      highlightColor: Colors.black26,
      child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Obx(() => ListTile(
                leading: IconButton(
                  onPressed: () {},
                  icon: !Get.find<RequestsController>().pageEnd.value
                      ? const Icon(Icons.delete)
                      : const Icon(Icons.close),
                  color: Colors.black,
                ),
                title: !Get.find<RequestsController>().pageEnd.value
                    ? Container(
                        width: Get.width / 7,
                        height: 8.0,
                        color: Colors.white,
                      )
                    : const Text("no more data to show"),
                subtitle: Container(
                  width: Get.width / 5,
                  height: 8.0,
                  color: Colors.white,
                ),
              ))),
    );
  }

  parsNumbers(String string, String locale) {
    // if(locale == 'en'){
    //   return arabicToEnglish(NumberFormat("###,###.##", locale)
    //       .format(double.parse(string)));
    // }
    // else
    if (locale == 'ar') {
      return englishToArabic(string);
    }
    return string;
  }

  englishToArabic(String string) {
    StringBuffer sb = StringBuffer();
    for (int i = 0; i < string.length; i++) {
      sb.write(ListViewBody.arabicDigits[string[i]] ?? string[i]);
    }
    return sb.toString();
  }

  arabicToEnglish(String string) {
    StringBuffer sb = StringBuffer();
    for (int i = 0; i < string.length; i++) {
      sb.write(ListViewBody.englishDigits[string[i]] ?? string[i]);
    }
    return sb.toString();
  }
}
