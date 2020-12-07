import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<bool> flutterToast({
  String msg,
  Color textColor = Colors.black,
  Color backgroundColor,
}) {
  return Fluttertoast.showToast(
    msg: msg,
    backgroundColor: backgroundColor,
    textColor: textColor,
  );
}
