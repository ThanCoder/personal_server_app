import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';

void showMessage(BuildContext context, String msg, {bool isOldStyle = false}) {
  if (isOldStyle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
      ),
    );
    return;
  }
  CherryToast.success(
    title: Text(msg),
    inheritThemeColors: true,
  ).show(context);
}

void showDialogMessage(BuildContext context, String msg) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      scrollable: true,
      content: Text(msg),
    ),
  );
}

void showDialogMessageWidget(BuildContext context, Widget child) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      scrollable: true,
      content: child,
    ),
  );
}
