import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final bool isEmailVerified;
  final String? displayName;

  const AuthUser({required this.isEmailVerified, this.displayName});

  factory AuthUser.fromFirebase(User user) => AuthUser(
      isEmailVerified: user.emailVerified, displayName: user.displayName);
}
