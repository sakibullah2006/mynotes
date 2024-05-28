import 'package:flutter/material.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Register"),
        titleTextStyle: const TextStyle(
          letterSpacing: 2.0,
          fontSize: 24
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 0.0,
      ),
      body: const Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Loading...")
        ],
      )),
    );
  }
}
