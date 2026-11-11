/// Range of days queried, both ends included.
class AttendancePeriod {
  /// Creates the period; throws [ArgumentError] when [from] is after [to].
  AttendancePeriod({required DateTime from, required DateTime to})
      : from = _dateOnly(from),
        to = _dateOnly(to) {
    if (this.from.isAfter(this.to)) {
      throw ArgumentError('La fecha de inicio no puede ser posterior a la de fin.');
    }
  }

  /// From the first day of the month of [today] until [today].
  factory AttendancePeriod.currentMonth([DateTime? today]) {
    final DateTime now = today ?? DateTime.now();
    return AttendancePeriod(from: DateTime(now.year, now.month), to: now);
  }

  final DateTime from;
  final DateTime to;

  static DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  @override
  bool operator ==(Object other) => other is AttendancePeriod && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);
}
