import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Loader {
  Loader._internal();

  static final Loader instance = Loader._internal();

  bool _isShowing = false;

  void show({String? message}) {
    if (_isShowing) return;

    _isShowing = true;
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    message ?? 'Loading...',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void hide() {
    print('hide called:_isShowing:$_isShowing');
    if (_isShowing) {
      Navigator.of(Get.context!).pop();
      _isShowing = false;
    }
  }

  bool get isShowing => _isShowing;
}
