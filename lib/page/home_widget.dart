import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/controller/state_controller.dart';

import '../controller/camera_controller.dart';
import '../controller/requests_controller.dart';
import 'component/camera_app.dart';
import 'component/list_view_body.dart';

class HomePage extends GetView<TodoController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: controller.scaffoldKey,
        appBar: AppBar(
          backgroundColor: controller.color,
          actions: [
            Obx(
              () => Icon(controller.darkIcon),
            )
          ],
          title: Text(
            'title'.tr,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        drawer: Drawer(
            width: context.width * (3 / 4),
            child: Column(
              children: [
                Obx(
                  () => Container(
                    color: controller.color,
                    height: context.height * (1 / 4),
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
                  leading: const Icon(Icons.info),
                  title: Text("more".tr),
                  onTap: () async {
                    controller.logEvent("more_info_selected");
                    await Get.find<RequestsController>().empty();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                  ),
                  title: Text("crash".tr),
                  onTap: () async {
                    controller.logEvent("error_occurred");
                    controller.error();
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
                  leading: Obx(() => controller.locationLoading.value
                      ? const Icon(Icons.location_searching)
                      : const Icon(Icons.my_location)),
                  title: Obx(() => controller.locationLoading.value
                      ? const Text("Computing ")
                      : const Text("Compute GeoHash")),
                  onTap: () async {
                    FirebaseAnalytics.instance.logEvent(
                        name: "todo_ready", parameters: {'todo_date': 'ready'});
                    controller.getLocation();
                  },
                ),
                IconButton(
                    onPressed: () async {
                      print("isNotInit");
                      await Get.find<CustomCameraController>().init();
                      print("isInit");
                      await Get.find<CustomCameraController>().getImages();
                      await Get.to(() => const CameraApp());
                    },
                    icon: const Icon(Icons.camera)),
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
              child: const Icon(Icons.add),
              onPressed: () async {
                controller.logEvent("list_tile_pressed");
                controller.showAddTodoOverlay();
              },
            )),
      ),
    );
  }

  handleMessage(RemoteMessage message) async {
    Get.snackbar(message.notification!.title!, message.notification!.body!);
  }
}
