import 'dart:developer';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:todo_app/controller/state_controller.dart';

import '../controller/camera_controller.dart';
import '../controller/requests_controller.dart';
import 'component/camera_app.dart';
import 'component/list_view_body.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return  homeScreen();
  }
  handleMessage(RemoteMessage message) async {
    Get.snackbar(message.notification!.title!, message.notification!.body!);
  }
  homeScreen() {
    var controller = Get.find<TodoController>();
    return SafeArea(
        child: Scaffold(
          drawerEnableOpenDragGesture: true,
          drawerEdgeDragWidth: 0,
          appBar: AppBar(
            titleSpacing: 0,
            backgroundColor: controller.color,
            title: Text(
              'title'.tr,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          drawer: Drawer(
              elevation: 10,
              width: (Get.context!.width) * (3 / 4),
              child: Column(
                children: [
                  Obx(
                    () => Container(
                      color: controller.color,
                      height: (Get.context!.height) * (1 / 4),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: Image(
                                  image: AssetImage('assets/flutter.png'),
                                  width: 100,
                                )),
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: Text(
                                "menu".tr,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Obx(
                    () => ListTile(
                      title: Text("theme".tr),
                      onTap: () {
                        controller.logEvent("list_tile_pressed");
                        controller.changeTheme();
                      },
                      leading: Icon(controller.modeIcon),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ListTile(
                    title: Text("language".tr),
                    leading: const Icon(Icons.translate),
                    trailing: DropdownMenu(
                      dropdownMenuEntries: [
                        DropdownMenuEntry(value: 'en', label: 'English'.tr),
                        DropdownMenuEntry(value: 'ar', label: 'Arabic'.tr),
                      ],
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      hintText: "default_language".tr,
                      initialSelection: 'English',
                      onSelected: (val) async => {
                        controller.logEvent("drop_down_menu_selected"),
                        controller.changeLanguage(val),
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  ListTile(
                    leading: Obx(() => controller.locationLoading.value
                        ? const Icon(Icons.location_searching)
                        : const Icon(Icons.my_location)),
                    title: Obx(() => controller.locationLoading.value
                        ? Text('Computing'.tr)
                        : Text('Compute GeoHash'.tr)),
                    onTap: () async {
                      FirebaseAnalytics.instance.logEvent(
                          name: "todo_ready",
                          parameters: {'todo_date': 'ready'});
                      controller.getLocation();
                    },
                  ),
                  // ListTile(
                  //   leading: const Icon(
                  //     Icons.error_outline,
                  //     color: Colors.red,
                  //   ),
                  //   title: Text("crash".tr),
                  //   onTap: () async {
                  //     controller.logEvent("error_occurred");
                  //     controller.error();
                  //   },
                  // ),
                  ListTile(
                      title: Text('camera'.tr),
                      onTap: () async {
                        await Get.find<CustomCameraController>().init();
                        await Get.find<CustomCameraController>().getImages();
                        await Get.to(() => const CameraApp());
                      },
                      leading: const Icon(Icons.camera)),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: Text("more".tr),
                    onTap: () async {
                      controller.logEvent("more_info_selected");
                      await Get.find<RequestsController>().empty();
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.red,
                    ),
                    title: Text("logout".tr),
                    onTap: () async {
                      Get.find<RequestsController>().logout();
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.text_fields,
                      color: Colors.red,
                    ),
                    title: Text("logout".tr),
                    onTap: () async {
                      Get.toNamed('/text', parameters: {'text': '123456'});
                    },
                  ),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.bottomEnd,
                      child: Text(controller.hash),
                    ),
                  )
                ],
              )),
          body: Center(
            child: Obx(() => ListViewBody(
                  locale: controller.locale.value!.languageCode,
                )),
          ),
          floatingActionButton: Obx(() => FloatingActionButton(
                // title: Text("add".tr),
                backgroundColor: controller.color,
                child: Obx(() => Get.find<TodoController>().darkMode.value
                    ? const Icon(
                        Icons.add,
                        color: Colors.white,
                      )
                    : const Icon(Icons.add, color: Colors.black)),
                onPressed: () async {
                  controller.logEvent("list_tile_pressed");
                  controller.showAddTodoOverlay();
                },
              )),
        ),
      );
  }
}
