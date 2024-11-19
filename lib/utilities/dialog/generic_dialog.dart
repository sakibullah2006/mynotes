import 'package:flutter/material.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function();

Future<T?> genericDialog<T>({
  required BuildContext context,
  required String title,
  required String message,
  required DialogOptionBuilder optionsBuilder,
}) {
  final options = optionsBuilder();
  return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: options.keys.map((optionTitle) {
              final value = options[optionTitle];
              return TextButton(
                onPressed: () {
                  if (value != null) {
                    Navigator.pop(context, value);
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Text(optionTitle),
              );
            }).toList(),
          ));
}
