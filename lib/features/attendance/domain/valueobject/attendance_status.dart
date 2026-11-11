/// Result of a work day for an employee.
enum AttendanceStatus {
  onTime,
  late,
  incomplete,
  absent,
  justified;

  /// True when the employee can send a justification for the day.
  bool get canBeJustified =>
      this == AttendanceStatus.late || this == AttendanceStatus.absent || this == AttendanceStatus.incomplete;
}
