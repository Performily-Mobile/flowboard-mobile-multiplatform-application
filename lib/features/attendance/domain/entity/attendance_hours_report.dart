class AttendanceHoursReport {
  final int employeeId;
  final double effectiveHours, overtimeHours;

  const AttendanceHoursReport({
    required this.employeeId,
    required this.effectiveHours,
    required this.overtimeHours,
  });
}