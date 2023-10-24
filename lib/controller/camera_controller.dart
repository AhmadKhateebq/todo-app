import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

class CustomCameraController extends GetxController {
  late final List<CameraDescription> cameras;
  late final CameraDescription frontCamera;
  late final CameraDescription rearCamera;
  var paths = <Uint8List>[].obs;
  List<ImAt> data = [];
  XFile? image;
  Rx<Image?> selectedImage = Rx(null);
  late CameraController cameraController;
  var isInit = false;
  bool back = true;

  init() async {
    if (isInit) {
      return;
    }
    if (await Permission.camera.isDenied) {
      isInit = false;
      await Permission.camera.request();
      init();
      return;
    }
    if (await Permission.camera.isGranted) {
      cameras = await availableCameras();
      rearCamera = cameras.first;
      frontCamera = cameras.last;
      cameraController = CameraController(rearCamera, ResolutionPreset.max);
      await cameraController.initialize();
      isInit = true;
    }
    if (await Permission.camera.isPermanentlyDenied) {
      return false;
    }
  }

  switchCamera() {
    if (isInit) {
      cameraController.setDescription(back ? frontCamera : rearCamera);
      back = !back;
    }
  }

  capture() async {
    image = await cameraController.takePicture();
    var captured = File(image!.path);
    selectedImage.value = Image.file(captured);
  }

  getImages() async {
    List<ImAt> images = [];
    List<String> ids = [];
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      // Granted.
      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(onlyAll: true);
      for (var value in paths) {
        log(value.name.toString(),name: 'name');
        log(value.isAll.toString(),name: 'isAll');
        log(value.albumType.toString(),name: "album type");
        if(value.name != 'Recent' && value.name !='Download'){
          print('continue');
          continue;
        }
        // for (var value1 in (await value.getAssetListRange(start: 0, end: 1))) {
        for (var value1
            in (await value.getAssetListPaged(page: 0, size: 100))) {
          File image = (await value1.file)!;
          final extension = p.extension(image.path);
          if (extension == '.jpeg' ||
              extension == '.jpg' ||
              extension == '.png' ||
              extension == '.img') {
            var a = await value1.thumbnailData;
            ImAt imAt = ImAt(
              path: image.path,
                thumbnail: a!,
                createdTime: value1.createDateTime,
                id: value1.id);
            if (!ids.contains(imAt.id)) {
              ids.add(value1.id);
              images.add(imAt);
            }
          }
        }
      }
      images.sort((a, b) => b.createdTime.compareTo(a.createdTime));
      this.paths.value = images.map((e) => e.thumbnail).toList();
      data = images;
    } else {
      // Limited(iOS) or Rejected, use `==` for more precise judgements.
      // You can call `PhotoManager.openSetting()` to open settings for further steps.
    }
  }
  setImage(int index){
    selectedImage.value = Image.file(File(data[index].path),fit: BoxFit.contain,);
    image = XFile(data[index].path,bytes: data[index].thumbnail,lastModified: data[index].createdTime);
  }
  setImageFromPath(String path){
    selectedImage.value = Image.file(File(path),fit: BoxFit.contain,);
  }
  resetImage(){
    selectedImage.value = null;
    image = null;
  }
}

class ImAt {
  String id;
  String path;
  Uint8List thumbnail;
  DateTime createdTime;

  ImAt({required this.thumbnail,required this.path ,required this.createdTime, required this.id});

  @override
  String toString() {
    return 'ImAt{id: $id, path: $thumbnail, createdTime: $createdTime}';
  }
}
