import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Loader {
  Loader._internal();

  static final Loader instance = Loader._internal();

  BuildContext? _dialogContext;
  bool _isShowing = false;

  void show({String? message}) {
    if (_isShowing) return;

    _isShowing = true;
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (ctx) {
        _dialogContext = ctx;
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
    if (_isShowing && _dialogContext != null) {
      Navigator.of(_dialogContext!).pop();
      _dialogContext = null;
      _isShowing = false;
    }
  }

  bool get isShowing => _isShowing;
}
