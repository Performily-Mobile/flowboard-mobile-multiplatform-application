/// Digit rules shared by the quantities of Benefits.
///
/// The Android app validates with `BigDecimal`; Dart has no decimal type, so the digits are read
/// from the shortest text of the value, which is exact for the amounts typed in the forms.
class DecimalRules {
  const DecimalRules._();

  /// Number of decimals of [value] without trailing zeros: 2.50 has 1, 3 has 0.
  static int decimals(double value) {
    final String text = _plain(value);
    final int dot = text.indexOf('.');
    return dot < 0 ? 0 : text.length - dot - 1;
  }

  /// Number of digits of the integer part of [value]: 1240.5 has 4.
  static int integerDigits(double value) => value.abs().truncate().toString().length;

  static String _plain(double value) {
    String text = value.abs().toStringAsFixed(6);
    if (text.contains('.')) text = text.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    return text;
  }
}
