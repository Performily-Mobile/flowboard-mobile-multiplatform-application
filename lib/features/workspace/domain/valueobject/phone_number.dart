/// Phone number of 7 to 15 digits, optionally with a leading plus sign.
class PhoneNumber {
  /// Creates the number; throws [ArgumentError] when [value] is blank or not a valid phone.
  PhoneNumber(this.value) {
    if (value.trim().isEmpty) throw ArgumentError('Este campo es obligatorio.');
    if (!_phonePattern.hasMatch(value)) throw ArgumentError('Ingresa un teléfono de 7 a 15 dígitos.');
  }

  /// Creates the number removing the spaces and hyphens the user may have typed.
  factory PhoneNumber.of(String raw) => PhoneNumber(raw.replaceAll(' ', '').replaceAll('-', ''));

  static final RegExp _phonePattern = RegExp(r'^\+?\d{7,15}$');

  final String value;

  @override
  bool operator ==(Object other) => other is PhoneNumber && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
