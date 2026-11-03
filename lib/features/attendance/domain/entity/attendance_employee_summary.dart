class AttendanceEmployeeSummary {
  final int employeeId;
  final int punctual, late, absent;

  const AttendanceEmployeeSummary({
    required this.employeeId,
    required this.punctual,
    required this.late,
    required this.absent,
  });
}