import 'package:flutter/material.dart';

class NameFrame extends StatelessWidget {
  final String text;

  const NameFrame({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: CircleAvatar(
        radius: 18, // Adjust the size of the circle here
        backgroundColor: Colors.blue, // Change the color as needed
        child: Text(
          text.isNotEmpty ? text[0].toUpperCase() : '',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16, // Adjust font size for the letter
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
