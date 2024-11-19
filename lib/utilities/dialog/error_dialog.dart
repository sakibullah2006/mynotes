import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialog/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String errorText,
) {
  return genericDialog(
    context: context,
    title: 'Error',
    message: errorText,
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
