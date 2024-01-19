import 'package:flutter/material.dart';
import 'package:flutter_flushbar/flutter_flushbar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smallbiz/utils/colors.dart';

class WarningHelper {
  static void showWarningDialog(context, String title, String message) {
    Flushbar(
      borderRadius: BorderRadius.circular(10),
      duration: const Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: const Duration(seconds: 2),
      barBlur: 3,
      backgroundColor: Colors.black.withOpacity(0.7),
      title: title,
      message: message,
    ).show(context);
  }

  static void toastMessage(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: buttonColor.withOpacity(0.6),
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static void showProgressDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(
              color: buttonColor,
              backgroundColor: white,
              strokeWidth: 3,
            ),
          );
        });
  }
}
