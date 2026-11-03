class AttendancePeriod {
  const AttendancePeriod(this.from, this.to);

  final DateTime from, to;

  bool get isValid => !from.isAfter(to);
}