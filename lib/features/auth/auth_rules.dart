class AuthRules {
  static const int minPasswordLength = 8;

  static const int minUsernameLength = 3;

  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
  static final RegExp _username = RegExp(r'^[A-Za-z0-9._-]+$');
  static final RegExp _uniqueCharacter = RegExp(r'[^A-Za-z0-9]');

  static bool isEmail(String value) => _email.hasMatch(value.trim());

  static String? emailError(String value) {
    final email = value.trim();
    if (email.isEmpty) return 'Please enter your email address.';
    if (!isEmail(email)) {
      return 'Enter a valid email address, e.g. name@gmail.com.';
    }
    return null;
  }

  static String? passwordError(String value) {
    if (value.isEmpty) return 'Please enter a password.';
    if (value.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters.';
    }
    if (!_uniqueCharacter.hasMatch(value)) {
      return 'Password must contain at least 1 unique character (e.g. !, @, #).';
    }
    return null;
  }

  static String? loginIdentifierError(String value) {
    final identifier = value.trim();
    if (identifier.isEmpty) return 'Please enter your username or email.';
    if (identifier.contains('@')) {
      return isEmail(identifier)
          ? null
          : 'Enter a valid email address, e.g. name@gmail.com.';
    }
    if (identifier.length < minUsernameLength) {
      return 'Username must be at least $minUsernameLength characters.';
    }
    if (!_username.hasMatch(identifier)) {
      return 'Username may only contain letters, numbers, dot, dash '
          'or underscore.';
    }
    return null;
  }
}
