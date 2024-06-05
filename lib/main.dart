// ignore_for_file: dead_code, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:mynotes/constant/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/notes_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/varify_email.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: "Mynotes app",
    debugShowCheckedModeBanner: false,
    routes: {
      loginRoute: (context) => const LoginView(),
      registerRoute: (context) => const RegisterView(),
      varifyEmailRoute: (context) => const VarifyEmailView(),
      notesRoute: (context) => const NotesView(),
    },
    home: HomePage(),
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return NotesView();
              } else {
                return VarifyEmailView();
              }
            } else {
              return LoginView();
            }
          default:
            return Text('Loading...');
        }
      },
    );
  }
}
