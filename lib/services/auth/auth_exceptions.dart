// login exceptions
class UserNotFoundAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}

// Rrsgitration exceptions

class UserAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

class WeakPasswordAuthException implements Exception {}

// Other exceptions
class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}
