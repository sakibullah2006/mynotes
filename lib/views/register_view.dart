import 'package:flutter/material.dart';
import 'package:mynotes/constant/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _confirmPassword;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _confirmPassword = TextEditingController();
    super.initState();
  }

  Future _signup() async {
    final email = _email.text;
    final password = _password.text;
    final confirmPassword = _confirmPassword.text;

    try {
      if (password == confirmPassword) {
        await AuthService.firebase()
            .createUser(email: email, password: password);
        AuthService.firebase().sendEmailVerification();
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(
          varifyEmailRoute,
          (route) => false,
        );
      } else {
        showErrorDialog(context, "Confirmed password does not match");
      }
    } on InvalidEmailAuthException {
      showErrorDialog(context, "Invalid Email!");
    } on WeakPasswordAuthException {
      showErrorDialog(context, "Your password is weak!");
    } on UserAlreadyInUseAuthException {
      showErrorDialog(context, "Email already in Use!");
    } on GenericAuthException {
      showErrorDialog(context, "Sign up failed!");
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        // minimum: EdgeInsets.symmetric(vertical: 10),
        child: Center(
            child: ListView(
          primary: false,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // logo Icon
                Icon(
                  Icons.android,
                  size: 130.0,
                  color: Colors.blueGrey[800],
                ),
                // Hello Text
                const Text(
                  "Welcome",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                // enter text
                const Text(
                  "Enter your info below to Sign up",
                  style: TextStyle(fontSize: 20),
                ),
                // email field
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _email,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                        border: InputBorder.none,
                        hintText: 'email',
                      ),
                    ),
                  ),
                ),
                // password field
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                        border: InputBorder.none,
                        hintText: 'password',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // confirm password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _confirmPassword,
                      obscureText: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                        border: InputBorder.none,
                        hintText: 'confirm password',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // sing in button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: _signup,
                    child: Container(
                      width: double.maxFinite,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.deepPurple,
                      ),
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account!"),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            loginRoute, (route) => false);
                      },
                      child: const Text(
                        "Login Now!",
                        style: TextStyle(color: Colors.lightBlue),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        )),
      ),
    );
  }
}
