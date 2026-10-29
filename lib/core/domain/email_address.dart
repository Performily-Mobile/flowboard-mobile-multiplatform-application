/// Valid email address.
class EmailAddress {
  /// Creates the address; throws [ArgumentError] when [value] is blank or has an invalid format.
  EmailAddress(this.value) {
    if (value.trim().isEmpty) {
      throw ArgumentError('Este campo es obligatorio.');
    }
    if (!_pattern.hasMatch(value)) {
      throw ArgumentError('Ingresa un correo con formato válido.');
    }
  }

  final String value;

  static final RegExp _pattern = RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

  @override
  bool operator ==(Object other) => other is EmailAddress && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
