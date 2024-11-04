import 'package:flutter_test/flutter_test.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';

void main() {
  group("Authentication Tests", () {
    final provider = MockAuthProvider();

    setUp(() async {
      await provider.initialize();
    });

    test("Initialize should set isInitialized to true", () {
      expect(provider.isInitialized, true);
    });

    test("Create user with valid credentials should succeed", () async {
      final user = await provider.createUser(
        name: 'sakib',
        email: 'valid@email.com',
        password: 'validpassword',
      );
      expect(user, isA<AuthUser>());
      expect(user.isEmailVerified, false);
    });

    test("Login with invalid email should throw UserNotFoundAuthException", () {
      expect(
        () => provider.login(email: 'invalid@email.com', password: 'password'),
        throwsA(isA<UserNotFoundAuthException>()),
      );
    });

    test("Login with invalid password should throw WrongPasswordAuthException",
        () {
      expect(
        () =>
            provider.login(email: 'valid@email.com', password: 'wrongpassword'),
        throwsA(isA<WrongPasswordAuthException>()),
      );
    });

    test("Logout should set currentUser to null", () async {
      await provider.createUser(
          name: 'sakib', email: 'test@email.com', password: 'password');
      await provider.logout();
      expect(provider.currentUser, isNull);
    });

    test("sendEmailVerification should throw if user is null", () {
      expect(
        () => provider.sendEmailVerification(),
        throwsA(isA<UserNotFoundAuthException>()),
      );
    });

    test("Multiple initializations should not change isInitialized", () async {
      await provider.initialize();
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test("Create user with existing email should throw", () {
      expect(
        () => provider.createUser(
            name: 'sakib', email: 'admin', password: 'newpassword'),
        throwsA(isA<EmailAlreadyInUseAuthException>()),
      );
    });
  });
}

class EmailAlreadyInUseAuthException implements Exception {}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;

  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'admin') throw EmailAlreadyInUseAuthException();
    await Future.delayed(const Duration(milliseconds: 500));
    return login(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'invalid@email.com') throw UserNotFoundAuthException();
    if (password == 'wrongpassword') throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logout() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(milliseconds: 500));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
  }

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isInitialized = true;
  }
}


// class NotInitializedException implements Exception {}

// class MockAuthProvider implements AuthProvider {
//   AuthUser? _user;
//   var _isInitialized = false;

//   bool get isInitialized => _isInitialized;

//   @override
//   Future<AuthUser> createUser({
//     required String email,
//     required String password,
//   }) async {
//     if (!isInitialized) throw NotInitializedException();
//     await Future.delayed(const Duration(seconds: 1));
//     return login(
//       email: email,
//       password: password,
//     );
//   }

//   @override
//   AuthUser? get currentUser => _user;

//   @override
//   Future<AuthUser> login({
//     required String email,
//     required String password,
//   }) {
//     if (!isInitialized) throw NotInitializedException();
//     if (email == 'foobar@email.com') throw UserNotFoundAuthException();
//     if (password == 'foobar') throw WrongPasswordAuthException();
//     const user = AuthUser(isEmailVerified: false);
//     _user = user;
//     return Future.value(user);
//   }

//   @override
//   Future<void> logout() async {
//     if (!isInitialized) throw NotInitializedException();
//     if (_user == null) throw UserNotFoundAuthException();
//     await Future.delayed(const Duration(seconds: 1));
//     _user = null;
//   }

//   @override
//   Future<void> sendEmailVerification() async {
//     if (!isInitialized) throw NotInitializedException();
//     final user = _user;
//     if (user == null) throw UserNotFoundAuthException();
//     const newUser = AuthUser(isEmailVerified: true);
//     _user = newUser;
//   }

//   @override
//   Future<void> initialize() async {
//     await Future.delayed(const Duration(seconds: 1));
//     _isInitialized = true;
//   }
// }
