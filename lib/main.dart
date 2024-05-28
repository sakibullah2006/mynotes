import 'package:flutter/material.dart';
import 'package:mynotes/views/register_view.dart';

void main() {
  runApp( const MaterialApp(
    title: "Mynotes app",
    debugShowCheckedModeBanner: false,
    home: HomePage(),
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RegisterView();
  }
}
