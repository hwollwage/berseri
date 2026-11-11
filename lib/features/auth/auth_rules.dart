class AuthRules {
  static const int minPasswordLength = 8;
  static const int minFullNameLength = 2;
  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
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

  static String? fullNameError(String value) {
    if (value.trim().length < minFullNameLength) {
      return 'Please enter your full name.';
    }
    return null;
  }
}