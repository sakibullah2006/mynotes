import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialog/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext contex) {
  return genericDialog(
    context: contex,
    title: "Delete Note",
    message: "Are you sure you want to delete this note?",
    optionsBuilder: () => {
      "Yes": true,
      "No": false,
    },
  ).then((value) => value ?? false);
}
