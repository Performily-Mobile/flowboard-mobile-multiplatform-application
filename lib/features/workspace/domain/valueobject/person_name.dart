/// First and last name of a person.
class PersonName {
  /// Creates the name; throws [ArgumentError] when a part is blank, too long or has characters
  /// other than letters, spaces, apostrophes and hyphens.
  PersonName(this.firstName, this.lastName) {
    if (firstName.trim().isEmpty) throw ArgumentError('Los nombres son obligatorios.');
    if (lastName.trim().isEmpty) throw ArgumentError('Los apellidos son obligatorios.');
    if (firstName.length > 50) throw ArgumentError('Los nombres admiten hasta 50 caracteres.');
    if (lastName.length > 80) throw ArgumentError('Los apellidos admiten hasta 80 caracteres.');
    if (!_namePattern.hasMatch(firstName)) {
      throw ArgumentError('Los nombres solo admiten letras, espacios, apóstrofos y guiones.');
    }
    if (!_namePattern.hasMatch(lastName)) {
      throw ArgumentError('Los apellidos solo admiten letras, espacios, apóstrofos y guiones.');
    }
  }

  static final RegExp _namePattern = RegExp(r"^[\p{L} '\-]+$", unicode: true);

  final String firstName;
  final String lastName;

  /// "First Last".
  String get fullName => '$firstName $lastName';

  /// "Last, First", used to sort lists.
  String get sortableName => '$lastName, $firstName';

  /// First letter of the first and last name, in uppercase.
  String get initials {
    final String first = String.fromCharCode(firstName.trim().runes.first);
    final String last = String.fromCharCode(lastName.trim().runes.first);
    return '$first$last'.toUpperCase();
  }
}
