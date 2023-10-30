import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io' show Platform;
import 'package:uni_links/uni_links.dart';

class ShowTextPage extends StatefulWidget {
  const ShowTextPage({super.key});

  @override
  State<ShowTextPage> createState() => _ShowTextPageState();
}

class _ShowTextPageState extends State<ShowTextPage> {
  var data = ''.obs;
  var info = ''.obs;

  @override
  void initState() {
    super.initState();
    setReferrerIdFromUri();
  }

  Future<void> setReferrerIdFromUri() async {
    info.value = '${info.value} ${kIsWeb}';
    String queryData = Get.parameters['text']!;
    setState(() {
      data.value = queryData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('HELLOOO'),
        Obx(() => Text(info.value)),
        Center(
          child: Obx(()=>Text(data.value)),
        ),
      ],
    );
  }
}
