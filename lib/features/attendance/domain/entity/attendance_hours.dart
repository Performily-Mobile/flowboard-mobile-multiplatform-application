/// Worked and overtime hours of an employee in a period.
class AttendanceHours {
  /// Creates the hours.
  const AttendanceHours({required this.employeeId, required this.workedHours, required this.overtimeHours});

  final int employeeId;
  final double workedHours;
  final double overtimeHours;
}
