import 'dart:developer';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:todo_app/controller/state_controller.dart';
import 'package:todo_app/util/consts.dart';

import '../controller/camera_controller.dart';
import '../controller/requests_controller.dart';
import '../data/to_do_object.dart';
import 'component/camera_app.dart';

class AddAndEdit extends GetView<TodoController> {
  AddAndEdit({
    super.key,
    required this.edit,
    required this.title,
    required this.date,
    this.imageUrl,
    this.todoName,
    this.todo,
  });

  final bool edit;
  final String title;
  DateTime date;
  String? imageUrl;
  String? todoName;
  ToDo? todo;

  @override
  Widget build(BuildContext context) {
    bool dateChosen = false;
    XFile? image;
    var dateFormatter = DateFormat('dd MMM y', Get.locale?.languageCode);
    var choose = false.obs;
    var dateString = dateFormatter.format(date).obs;
    TextEditingController textController =
        TextEditingController(text: todoName ?? '');
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(title.tr),
          backgroundColor: controller.color,
        ),
        body: Column(
          children: [
            SizedBox(
                height: 250,
                child: FilledButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: (imageUrl == null)
                        ? Obx(() => !choose.value
                            ? Image.network(noImage)
                            : kIsWeb
                                ? Image.network(image!.path)
                                : Image.file(io.File(image!.path)))
                        : Image.network(imageUrl!),
                  ),
                  onPressed: () async {
                    if (kIsWeb) {
                      choose.value = false;
                      image = await selectImageWeb();
                      if (image != null) {
                        choose.value = true;
                      }
                    } else {
                      await Get.find<CustomCameraController>().init();
                      await Get.find<CustomCameraController>().getImages();
                      choose.value = false;
                      await Get.to(() => const CameraApp());
                      if (Get.find<CustomCameraController>()
                              .selectedImage
                              .value !=
                          null) {
                        image = Get.find<CustomCameraController>().image;
                        choose.value = true;
                      }
                    }
                  },
                )),
            Container(
              padding: const EdgeInsets.all(10),
              color: Get.isDarkMode ? Colors.black87 : Colors.white70,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textController,
                          decoration: InputDecoration(
                            labelText: 'Todo Name'.tr,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                  onPressed: () async {
                                    date = await showDate() ?? DateTime.now();
                                    dateString.value =
                                        dateFormatter.format(date);
                                    dateChosen = true;
                                  },
                                  icon: const Icon(Icons.calendar_month)),
                              IconButton(
                                  onPressed: () async {
                                    choose.value = false;
                                    if (kIsWeb) {
                                      image = await selectImageWeb();
                                    } else {
                                      image = await selectImage();
                                    }
                                    if (image != null) {
                                      choose.value = true;
                                    }
                                  },
                                  icon: const Icon(Icons.photo)),
                            ],
                          ),
                          kIsWeb
                              ? SizedBox()
                              : IconButton(
                                  onPressed: () async {
                                    if (todo == null) {
                                      await Get.find<CustomCameraController>()
                                          .init();
                                      await Get.find<CustomCameraController>()
                                          .getImages();
                                      choose.value = false;
                                      await Get.to(() => const CameraApp());
                                      if (Get.find<CustomCameraController>()
                                              .selectedImage
                                              .value !=
                                          null) {
                                        image =
                                            Get.find<CustomCameraController>()
                                                .image;
                                        choose.value = true;
                                      }
                                    } else {
                                      imageUrl = todo?.imageUrl;
                                    }
                                  },
                                  icon: const Icon(Icons.camera_alt_outlined)),
                        ],
                      ),
                    ],
                  ),
                  Obx(() => Text('${'date'.tr} : $dateString')),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() {
                  return ElevatedButton(
                    style: getButtonStyle(),
                    onPressed: () {
                      Get.back();
                    },
                    child: Text('Back'.tr),
                  );
                }),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  style: getButtonStyle(),
                  onPressed: () async {
                    await getData(dateChosen, image, textController.text);
                    Get.back();
                  },
                  child: Text('Save'.tr),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  getButtonStyle() {
    return ElevatedButton.styleFrom(
        backgroundColor: Get.find<TodoController>().color,
        shape: const StadiumBorder());
  }

  editAndSave(bool dateChosen, String text) async {
    todo!.name = text;
    todo!.date = date;
    await Get.find<RequestsController>().editTodo(todo!);
  }

  getData(bool dateChosen, XFile? image, String text) async {
    controller.loading.value = true;
    // date = await showDate() ?? DateTime.now();
    if (!edit) {
      date = dateChosen ? date : (await showDate() ?? DateTime.now());
      try {
        imageUrl = await Get.find<RequestsController>().uploadImage(image!);
      } catch (e) {
        log(error: e, 'showAddTodoOverlay', name: 'ERROR');
        imageUrl = noImage;
      }
    }
    edit
        ? await editAndSave(dateChosen, text)
        : await addNew(dateChosen, image!, text);
    controller.logEvent("add_todo", {'name': text, 'date': date.toString()});
    controller.loading.value = false;
    Get.find<CustomCameraController>().resetImage();
  }

  addNew(bool dateChosen, XFile image, String text) async {
    var id = await Get.find<RequestsController>()
        .addTodo(ToDo(name: text, date: date, imageUrl: imageUrl));
    Get.find<RequestsController>().filteredTodos.add(
        ToDo(name: text, date: date, id: id.toString(), imageUrl: imageUrl));
  }

  selectImageWeb() async {
    var a = await ImagePicker().pickImage(source: ImageSource.gallery);

    return a;
  }

  Future<XFile?> selectImage() async {
    if (await Permission.storage.isGranted) {
      return await ImagePicker().pickImage(source: ImageSource.gallery);
    } else {
      var permission = await Permission.storage.request();
      if (permission.isGranted) {
        return await ImagePicker().pickImage(
          source: ImageSource.gallery,
        );
      } else {
        Get.snackbar(
            "storage Permissions not granted",
            "we cannot access your storage, "
                "so you wont be able to use any storage based features");
      }
    }
    return null;
  }

  Future<XFile?> takeImage() async {
    if (await Permission.camera.isGranted) {
      return await ImagePicker().pickImage(source: ImageSource.camera);
    } else {
      var permission = await Permission.camera.request();
      if (permission.isGranted) {
        return await ImagePicker().pickImage(source: ImageSource.camera);
      } else {
        Get.snackbar(
            "Camera Permissions not granted",
            "we cannot access your Camera, "
                "so you wont be able to use any Camera based features");
      }
    }
    return null;
  }

  Future<DateTime?> showDate() async {
    return showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 2),
      locale: controller.locale.value,
    );
  }
}
