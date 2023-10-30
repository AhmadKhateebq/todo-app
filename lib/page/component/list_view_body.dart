import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:todo_app/controller/state_controller.dart';
import 'package:todo_app/data/to_do_object.dart';
import 'package:todo_app/page/preview_todo.dart';
import 'package:todo_app/util/consts.dart';
import 'package:todo_app/util/language_changer.dart';

import '../../controller/requests_controller.dart';
import '../../data/debouncer_class.dart';

class ListViewBody extends StatefulWidget {
  const ListViewBody({super.key, required this.locale});

  final String locale;

  @override
  State<ListViewBody> createState() => _ListViewBodyState();
}

class _ListViewBodyState extends State<ListViewBody> {
  final debouncer = Debouncer(milliseconds: 300);
  bool search = false;

  @override
  void dispose() {
    super.dispose();
    Get.find<RequestsController>().cancelRequest();
  }

  List<String> get filters =>
      ['All', 'Expired', 'Deleted', 'Done', 'Not Finished'];

  @override
  Widget build(BuildContext context) {
    double leftPadding = 3;
    double rightPadding = 3;
    double topPadding = 0;
    double bottomPadding = 0;
    List<ToDo> list = Get
        .find<RequestsController>()
        .filteredTodos;
    final searchController = TextEditingController();
    // final textFieldKey = GlobalKey<EditableTextState>();
    Get.find<TodoController>().logEvent("main_screen_entered");
    return Obx(() =>
        Padding(
          padding: EdgeInsets.fromLTRB(
              leftPadding, topPadding, rightPadding, bottomPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Card(
                    // padding: EdgeInsets.fromLTRB(leftPadding,topPadding,rightPadding,bottomPadding),
                    child: SizedBox(
                      width: Get.width * (6.7 / 8),
                      child: TextField(
                        // key: textFieldKey,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                          border: const OutlineInputBorder(),
                          floatingLabelStyle: const TextStyle(
                            color: Colors.lightBlue,
                          ),
                          // border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyan),
                          ),
                          label: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                            child: Text("search".tr),
                          ),
                        ),
                        controller: searchController,
                        onChanged: (val) {
                          debouncer.run(() async {
                            search = true;
                            if (val == "" || val.isEmpty) {
                              await Get.find<RequestsController>().empty();
                              search = false;
                            } else {
                              var results = await Get.find<RequestsController>()
                                  .search(val);
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
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.filter_alt),
                    onSelected: Get
                        .find<RequestsController>()
                        .changeFilters,
                    itemBuilder: (context) {
                      return filters.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(
                            choice,
                            style: TextStyle(
                                color: Get.find<RequestsController>()
                                    .getFilterSet(choice)
                                    ? Colors.green
                                    : Colors.blueGrey),
                          ),
                        );
                      }).toList();
                    },
                  )
                ],
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
          ),
        ));
  }

  final _scrollController = ScrollController();

  Widget tileMaker(int index, ToDo todo) {
    return Card(
      child: Slidable(
        // key: const ValueKey(0),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (a) async {
                if (todo.cid != -9) {
                  Get.find<TodoController>()
                      .logEvent("item_deleted", {'index': index});
                  await Get.find<RequestsController>().delete(todo);
                } else {
                  await Get.find<RequestsController>().deleteForever(todo);
                }
                // list.removeAt(index);
              },
              backgroundColor: const Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              icon: todo.cid == -9 ? Icons.delete_forever : Icons.delete,
              label: todo.cid == -9 ? 'Delete Forever' : 'Delete',
            )
          ],
        ),
        endActionPane: ActionPane(
          extentRatio: (!(todo.done??true)||todo.cid==-9) ? 0.5 : 0.0000001,
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (a) async {
                if (todo.cid != -9) {
                  await Get.find<RequestsController>().done(todo);
                } else {
                  await Get.find<RequestsController>().restore(todo);
                }
                // list.removeAt(index);

              },
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              icon: todo.cid == -9 ? Icons.restore : Icons.done,
              label: todo.cid == -9 ? 'restore' : 'complete',
            )
          ],
        ),
        child: ListTile(
          onTap: (){
            Get.toNamed('/preview/',parameters: {
              'uid':'${Get.find<RequestsController>().userCredential['localId']}',
              'id':todo.id!
            });
          },
          trailing: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(todo.imageUrl ?? noImage, scale: .1),
                fit: BoxFit.cover,
              ),
            ),
            // child: Image.network(todo.imageUrl!),
          ),
          title: getText(todo),
          subtitle: Text(DateFormat.yMMMd(widget.locale).format(todo.date)),
        ),
      ),
    );
  }

  void _setupScrollController() {
    _scrollController.addListener(_scrollListener);
  }

  getText(ToDo todo) {
    Color color = Colors.transparent;
    String name = todo.name;
    if(todo.date.isBefore(DateTime.now())){
      color = Colors.orangeAccent;
    }
    if (todo.done!) {
      color = Colors.green;
    }
    if (todo.cid == -9) {
      color = Colors.red;
    }

    if(todo.cid == -9 && todo.done!){
      name = "$name (Completed)";
    }
    if (color == Colors.transparent) {
      return Obx(() =>
          Text(LocaleChanger.parsNumbers(name, (widget.locale)),
              style: TextStyle(color: Get
                  .find<TodoController>()
                  .darkMode
                  .value
                  ?Colors.white
                  :Colors.black
              )
          )
      );
    }
    return Text(LocaleChanger.parsNumbers(name, (widget.locale)),
        style: TextStyle(color: color));
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
        if (!Get
            .find<RequestsController>()
            .pageLock
            .value) {
          await Get.find<RequestsController>().fetchAnchoredData();
          await _scrollController.animateTo(
              _scrollController.position.maxScrollExtent - 50,
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn);
        }
      }
      if (Get
          .find<RequestsController>()
          .pageEnd
          .value) {
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
          child: Obx(() =>
          !Get
              .find<RequestsController>()
              .pageEnd
              .value
              ? ListTile(
            leading: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.delete),
              color: Colors.black,
            ),
            title: Container(
              width: Get.width / 7,
              height: 8.0,
              color: Colors.white,
            ),
            subtitle: Container(
              width: Get.width / 5,
              height: 8.0,
              color: Colors.white,
            ),
          )
              : const SizedBox())),
    );
  }

  init() {
    Drawer(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('todos'),
            onTap: () async {
              await Get.find<RequestsController>().empty();
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.timer_off_outlined,
              color: Colors.red,
            ),
            title: const Text('expired todos'),
            onTap: () async {
              // await Get.find<RequestsController>().changeFilters('expired', true);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.delete_forever_rounded,
              color: Colors.red,
            ),
            title: const Text('deleted todos'),
            onTap: () async {
              await Get.find<RequestsController>().getDeletedData();
            },
          ),
        ],
      ),
    );
  }

  streamWidget() {
    double leftPadding = 3;
    double rightPadding = 3;
    double topPadding = 0;
    double bottomPadding = 0;
    List<ToDo> list = Get
        .find<RequestsController>()
        .filteredTodos;
    final searchController = TextEditingController();
    // final textFieldKey = GlobalKey<EditableTextState>();
    Get.find<TodoController>().logEvent("main_screen_entered");
    return Padding(
      padding: EdgeInsets.fromLTRB(
          leftPadding, topPadding, rightPadding, bottomPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            // padding: EdgeInsets.fromLTRB(leftPadding,topPadding,rightPadding,bottomPadding),
            child: TextField(
              // key: textFieldKey,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                border: const OutlineInputBorder(),
                floatingLabelStyle: const TextStyle(
                  color: Colors.lightBlue,
                ),
                // border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyan),
                ),
                label: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Text("search".tr),
                ),
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
          ),
          // Expanded(
          //   child: ListView.builder(
          //       controller: scrollController,
          //       itemCount: list.length + 1,
          //       itemBuilder: (context, index) {
          //         return (index != list.length)
          //             ? tileMaker(index, list[index])
          //             : getLoadingTile();
          //       }),
          // ),
          StreamBuilder(
            builder: (context, snapshot) {
              return Expanded(
                child: ListView.builder(
                    controller: scrollController,
                    itemCount: list.length + 1,
                    itemBuilder: (context, index) {
                      return (index != list.length)
                          ? tileMaker(index, list[index])
                          : getLoadingTile();
                    }),
              );
            },
            stream: Get.find<RequestsController>()
                .fetchDataByPageStream(entries: 10),
          ),
        ],
      ),
    );
  }
}
