import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constant/routes.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  final List list = [1, 2, 3, 4, 5, 6, 69];

  Future logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
  }

  void _showlogoutdialog() {
    showDialog(
      context: context,
      builder: (contex) {
        return AlertDialog(
          surfaceTintColor: Colors.deepPurple[200],
          title: const Text("Log out"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: logout,
              child: const Text("Ok"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          backgroundColor: Colors.deepPurpleAccent,
          foregroundColor: Colors.white,
          title: const Text("My notes"),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _showlogoutdialog,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: const Text("no notes"));
  }
}
