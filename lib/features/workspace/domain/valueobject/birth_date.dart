/// Birth date of an employee; it cannot be later than today.
class BirthDate {
  /// Creates the birth date; throws [ArgumentError] when [value] is in the future.
  BirthDate(DateTime value) : value = DateTime(value.year, value.month, value.day) {
    final DateTime now = DateTime.now();
    if (this.value.isAfter(DateTime(now.year, now.month, now.day))) {
      throw ArgumentError('La fecha de nacimiento no puede ser posterior a hoy.');
    }
  }

  final DateTime value;

  /// Age in whole years on [date].
  int ageOn(DateTime date) {
    int age = date.year - value.year;
    if (date.month < value.month || (date.month == value.month && date.day < value.day)) age--;
    return age;
  }

  @override
  bool operator ==(Object other) => other is BirthDate && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
