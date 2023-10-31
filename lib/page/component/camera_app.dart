import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/data/debouncer_class.dart';

import '../../controller/camera_controller.dart';

// late List<CameraDescription> _cameras;

class CameraApp extends StatefulWidget {
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  final controller = Get.find<CustomCameraController>();
  var imageKey = GlobalKey();
  final db = Throttler(milliseconds: 500);
  var cameraLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Obx(
            () => controller.selectedImage.value != null
                ? Column(
                    children: [
                      Align(
                        alignment: AlignmentDirectional.topStart,
                        child: IconButton(
                          onPressed: () {
                            controller.selectedImage.value = null;
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ),
                      Container(
                        width: Get.width,
                        height: Get.height * (6.5 / 8),
                        child: controller.selectedImage.value,
                      ),
                    ],
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.scale(
                        scale: 1 /
                            (controller.cameraController.value.aspectRatio *
                                Get.size.aspectRatio),
                        alignment: Alignment.topCenter,
                        child: CameraPreview(controller.cameraController),
                      ),
                      SingleChildScrollView(
                        clipBehavior: Clip.none,
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          height: Get.height * (6.4 / 8),
                          width: Get.width,
                          child: Align(
                            child: Obx(
                              () => ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: controller.paths.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return imageFromMemoryButtonBuilder(
                                      controller.paths[index], index);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      Obx(() => controller.selectedImage.value == null
                          ? Positioned.fill(
                              child: Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  onPressed: controller.switchCamera,
                                  icon: const Icon(Icons.flip_camera_android),
                                ),
                              ),
                            )
                          : ButtonBar(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    controller.selectedImage.value = null;
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                                IconButton(
                                  onPressed: () {
                                    controller.selectedImage.value = null;
                                  },
                                  icon: const Icon(Icons.check),
                                ),
                              ],
                            )),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            onPressed: () {
                              controller.selectedImage.value = null;
                              Get.back();
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          floatingActionButton: OutlinedButton(
              style: OutlinedButton.styleFrom(
                  elevation: 1,
                  // backgroundColor: Colors.green,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(50, 50),
                  shape: const CircleBorder()),
              // onPressed: () {
              //   db.run(() async {
              //     if (controller.selectedImage.value != null) {
              //       Get.back();
              //     } else {
              //       await controller.capture();
              //     }
              //   });
              //
              // },
              onPressed: () async {
                if (controller.selectedImage.value != null) {
                  Get.back();
                } else {
                  if (!cameraLoading.value) {
                    cameraLoading.value = true;
                    await controller.capture();
                    cameraLoading.value = false;
                  }
                }
              },
              child: Obx(
                () => controller.selectedImage.value == null
                    ? Obx(() => cameraLoading.value
                        ? const CircularProgressIndicator()
                        : const Icon(
                            Icons.photo_camera_outlined,
                            color: Colors.black,
                          ))
                    : const Icon(
                        Icons.check,
                        color: Colors.green,
                      ),
              )),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat),
    );
  }

  Widget imageFromMemoryButtonBuilder(Uint8List bytes, int index) {
    // var child = Image.network(
    //   "https://upload.wikimedia.org/wikipedia/commons/1/14/No_Image_Available.jpg",
    //   height: 100,
    //   width: 100,
    // );
    var child = Image.memory(
      bytes,
      height: 80,
      width: 80,
      // fit: BoxFit.none,
      fit: BoxFit.cover,
    );
    return Align(
        alignment: Alignment.bottomCenter,
        widthFactor: .8,
        child: FilledButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: child,
          ),
          onPressed: () {
            controller.setImage(index);
            // controller.selectedImage.value = child;
          },
        ));
  }
}
