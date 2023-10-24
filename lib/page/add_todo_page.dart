import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:todo_app/controller/state_controller.dart';

import '../controller/camera_controller.dart';
import '../controller/requests_controller.dart';
import '../data/to_do_object.dart';
import 'component/camera_app.dart';

class AddTodo extends GetView<TodoController> {
  const AddTodo({super.key});

  @override
  Widget build(BuildContext context) {
    late DateTime date;
    bool dateChosen = false;
    late XFile? image;
    late String imageUrl;
    var choose = false.obs;
    var dateString =
        ("${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}")
            .obs;
    TextEditingController textController = TextEditingController();
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("add todo"),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Get.isDarkMode ? Colors.black87 : Colors.white70,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Add Todo'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textController,
                          decoration: const InputDecoration(
                            labelText: 'Todo Name',
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
                                        "${date.day}/${date.month}/${date.year}";
                                    dateChosen = true;
                                  },
                                  icon: const Icon(Icons.calendar_month)),
                              IconButton(
                                  onPressed: () async {
                                    choose.value = false;
                                    image = await selectImage();
                                    if (image != null) {
                                      choose.value = true;
                                    }
                                  },
                                  icon: const Icon(Icons.photo)),
                            ],
                          ),
                          // IconButton(
                          //     onPressed: () async {
                          //       choose.value = false;
                          //       image = await takeImage();
                          //       if(image!=null) {
                          //         choose.value = true;
                          //       }
                          //     },
                          //     icon: const Icon(Icons.camera_alt)),
                          IconButton(
                              onPressed: () async {
                                await Get.find<CustomCameraController>().init();
                                await Get.find<CustomCameraController>()
                                    .getImages();
                                choose.value = false;
                                await Get.to(() => const CameraApp());
                                if (Get.find<CustomCameraController>()
                                        .selectedImage
                                        .value !=
                                    null) {
                                  image =
                                      Get.find<CustomCameraController>().image;
                                  print(image!.path);
                                  choose.value = true;
                                }
                              },
                              icon: const Icon(Icons.camera_alt_outlined)),
                        ],
                      ),
                    ],
                  ),
                  Obx(() => Text('date : $dateString')),
                  ElevatedButton(
                    onPressed: () async {
                      controller.loading.value = true;
                      date = dateChosen
                          ? date
                          : (await showDate() ?? DateTime.now());
                      // date = await showDate() ?? DateTime.now();
                      try {
                        imageUrl = await Get.find<RequestsController>()
                            .uploadImage(image!);
                      } catch (e) {
                        log(error: e, 'showAddTodoOverlay', name: 'ERROR');
                        imageUrl =
                            "https://upload.wikimedia.org/wikipedia/commons/1/14/No_Image_Available.jpg";
                      }
                      final name = textController.text;
                      var id = await Get.find<RequestsController>().addTodo(
                          ToDo(name: name, date: date, imageUrl: imageUrl));
                      Get.find<RequestsController>().filteredTodos.add(ToDo(
                          name: name,
                          date: date,
                          id: id.toString(),
                          imageUrl: imageUrl));
                      controller.logEvent(
                          "add_todo", {'name': name, 'date': date.toString()});
                      controller.loading.value = false;
                      Get.find<CustomCameraController>().resetImage();
                      Get.back(); // Close the overlay
                    },
                    child: const Text('Save'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text('Back'),
                  ),
                ],
              ),
            ),
            // SizedBox(
            //   height: 500,
            //   child: Obx(
            //     () => !choose.value
            //         ? Image.network(
            //             "https://upload.wikimedia.org/wikipedia/commons/1/14/No_Image_Available.jpg")
            //         : Image.file(File(image!.path)),
            //   ),
            // ),
            SizedBox(
                height: 500,
                child: FilledButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Obx(
                      () => !choose.value
                          ? Image.network(
                              "https://upload.wikimedia.org/wikipedia/commons/1/14/No_Image_Available.jpg")
                          : Image.file(File(image!.path)),
                    ),
                  ),
                  onPressed: () async {
                    await Get.find<CustomCameraController>().init();
                    await Get.find<CustomCameraController>().getImages();
                    choose.value = false;
                    await Get.to(() => const CameraApp());
                    if (Get.find<CustomCameraController>()
                            .selectedImage
                            .value !=
                        null) {
                      image = Get.find<CustomCameraController>().image;
                      print(image!.path);
                      choose.value = true;
                    }
                  },
                )),
          ],
        ),
      ),
    );
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
