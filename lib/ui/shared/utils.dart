import 'dart:io';

import 'package:flutter/material.dart';


/// Contains useful functions to reduce boilerplate code
class Utils {
  static const double _FILE_SIZE_LIMIT_MB = 30;

  static Future<bool> isFileSizeOk(File file) async {
    final sizeInBytes = file.lengthSync().toDouble();
    final sizeInMb = sizeInBytes / (1024 * 1024).toDouble();
    print('sizeInMb: $sizeInMb');
    return sizeInMb <= _FILE_SIZE_LIMIT_MB;
  }

  static void showMessage(BuildContext context, String message, SnackBarAction action, Duration duration) {
    final snackBar = new SnackBar(
      content: Text(message),
      action: action,
      duration: duration,
    );

    Scaffold.of(context).showSnackBar(snackBar);
  }

}
