// import 'package:flutter_test/flutter_test.dart';
// import 'package:mynotes/services/auth/auth_provider.dart';
// import 'package:mynotes/services/auth/auth_service.dart';
// import 'package:mynotes/services/auth/auth_user.dart';
// import 'package:mocktail/mocktail.dart';

// class MockAuthProvider extends Mock implements AuthProvider {}

// void main() {
//   late AuthService authService;
//   late MockAuthProvider mockProvider;

//   setUp(() {
//     mockProvider = MockAuthProvider();
//     authService = AuthService(mockProvider);
//   });

//   test('createUser calls provider.createUser with correct parameters', () async {
//     final email = 'test@example.com';
//     final password = 'password123';
//     final mockUser = AuthUser(id: 'user123', isEmailVerified: false, email: email);

//     when(() => mockProvider.createUser(email: email, password: password))
//         .thenAnswer((_) async => mockUser);

//     final result = await authService.createUser(email: email, password: password);

//     verify(() => mockProvider.createUser(email: email, password: password)).called(1);
//     expect(result, equals(mockUser));
//   });

//   test('currentUser returns provider.currentUser', () {
//     final mockUser = AuthUser(id: 'user123', isEmailVerified: true, email: 'test@example.com');
//     when(() => mockProvider.currentUser).thenReturn(mockUser);

//     final result = authService.currentUser;

//     expect(result, equals(mockUser));
//   });

//   test('login calls provider.login with correct parameters', () async {
//     final email = 'test@example.com';
//     final password = 'password123';
//     final mockUser = AuthUser(id: 'user123', isEmailVerified: true, email: email);

//     when(() => mockProvider.login(email: email, password: password))
//         .thenAnswer((_) async => mockUser);

//     final result = await authService.login(email: email, password: password);

//     verify(() => mockProvider.login(email: email, password: password)).called(1);
//     expect(result, equals(mockUser));
//   });

//   test('logout calls provider.logout', () async {
//     when(() => mockProvider.logout()).thenAnswer((_) async {});

//     await authService.logout();

//     verify(() => mockProvider.logout()).called(1);
//   });

//   test('sendEmailVerification calls provider.sendEmailVerification', () async {
//     when(() => mockProvider.sendEmailVerification()).thenAnswer((_) async {});

//     await authService.sendEmailVerification();

//     verify(() => mockProvider.sendEmailVerification()).called(1);
//   });

//   test('initialize calls provider.initialize', () async {
//     when(() => mockProvider.initialize()).thenAnswer((_) async {});

//     await authService.initialize();

//     verify(() => mockProvider.initialize()).called(1);
//   });

//   test('firebase factory creates AuthService with FirebaseAuthProvider', () {
//     final firebaseAuthService = AuthService.firebase();
//     expect(firebaseAuthService.provider, isA<FirebaseAuthProvider>());
//   });
// }