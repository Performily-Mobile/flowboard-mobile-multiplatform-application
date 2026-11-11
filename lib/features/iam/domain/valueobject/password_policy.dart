/// Rules a new password must meet. They are the same rules the backend checks.
class PasswordPolicy {
  const PasswordPolicy._();

  /// Fewest characters a password can have.
  static const int minLength = 8;

  static final RegExp _upperCase = RegExp('[A-Z]');
  static final RegExp _lowerCase = RegExp('[a-z]');
  static final RegExp _digit = RegExp('[0-9]');
  static final RegExp _symbol = RegExp('[^a-zA-Z0-9]');

  /// True when [password] has at least [minLength] characters.
  static bool hasMinLength(String password) => password.length >= minLength;

  /// True when [password] has an uppercase and a lowercase letter.
  static bool hasUpperAndLowerCase(String password) =>
      _upperCase.hasMatch(password) && _lowerCase.hasMatch(password);

  /// True when [password] has a number.
  static bool hasDigit(String password) => _digit.hasMatch(password);

  /// True when [password] has a symbol, such as ! @ # or $.
  static bool hasSymbol(String password) => _symbol.hasMatch(password);

  /// True when [password] meets every rule.
  static bool isValid(String password) =>
      hasMinLength(password) && hasUpperAndLowerCase(password) && hasDigit(password) && hasSymbol(password);

  /// Throws [ArgumentError] when [password] does not meet every rule.
  static void ensureValid(String password) {
    if (!isValid(password)) {
      throw ArgumentError('Usa 8 caracteres, una mayúscula, una minúscula, un número y un símbolo.');
    }
  }
}
