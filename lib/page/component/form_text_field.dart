import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FormTextField extends StatelessWidget {
  FormTextField(
      {super.key,
      required String label,
      required bool Function(String?) validator,
      required this.controller,
      bool isPassword = false})
      : _isPassword = isPassword,
        _validator = validator,
        _label = label;

  final String _label;
  final _selected = false.obs;
  final bool Function(String?) _validator;
  final TextEditingController controller;
  final _changed = false.obs;
  final _focused = false.obs;
  bool valid = false;
  late final bool _isPassword;

  final _text = "".obs;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Focus(
          onFocusChange: (f) {
            if (f) {
              _focused.value = true;
            }
            if (!f) {
              if (_focused.value) {
                _text.value =
                    _validator(controller.text) ? "" : "This field is required";
              }
            }
          },
          child: Obx(
            () => TextField(
              obscureText: _isPassword,
              enableSuggestions: !_isPassword,
              autocorrect: !_isPassword,
              onTap: () {
                _selected.value = true;
              },
              onChanged: (text) => _changed.value = true,
              controller: controller,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                floatingLabelStyle: const TextStyle(color: Colors.deepPurple),
                // border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyan),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: _text.value == "" ? Colors.blue : Colors.red),
                ),
                labelText: _label,
                labelStyle: const TextStyle(color: Colors.black87),
              ),
            ),
          ),
        ),
        Obx(() => Text(
              _text.value,
              style: const TextStyle(color: Colors.red),
            )),
      ],
    );
  }

  validate() {
    _focused.value = true;
    if (_focused.value) {
      _validator(controller.text)
          ? {
              _text.value = "",
              valid = true,
            }
          : {valid = false, _text.value = "This field is required"};
    }
    return valid;
  }
}

class FormListValidator {
  FormListValidator();

  final List<FormTextField> _list = [];

  add(FormTextField field) {
    _list.add(field);
  }

  removeAt(int i) {
    _list.removeAt(i);
  }

  remove(FormTextField field) {
    _list.remove(field);
  }

  validateAll() {
    bool valid = true;
    for (var value in _list) {
      if (value.validate()) {
        valid = true;
      } else {
        valid = false;
      }
      return valid;
    }
  }
}
