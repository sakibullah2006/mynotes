import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final String email;
  final bool isEmailVerified;
  final String displayName;

  const AuthUser(
      {required this.email,
      required this.isEmailVerified,
      required this.displayName});

  factory AuthUser.fromFirebase(User user) => AuthUser(
        isEmailVerified: user.emailVerified,
        displayName: user.displayName!,
        email: user.email!,
      );
}
