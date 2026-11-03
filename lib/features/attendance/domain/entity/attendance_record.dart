class AttendanceRecord {
  const AttendanceRecord({
    required this.employeeId,
    required this.workDate,
    required this.status,
    this.id,
    this.employeeName,
    this.areaId,
    this.areaName,
    this.positionTitle,
    this.checkInTime,
    this.checkOutTime,
    this.effectiveHours,
    this.overtimeHours,
  });

  final int? id, areaId;
  final int employeeId;
  final String workDate, status;
  final String? employeeName, areaName, positionTitle, checkInTime, checkOutTime;
  final double? effectiveHours, overtimeHours;

  String get statusLabel => switch (status.toUpperCase()) {
        'ON_TIME' => 'Puntual',
        'LATE' => 'Tardanza',
        'ABSENT' => 'Inasistencia',
        'JUSTIFIED' => 'Justificada',
        'INCOMPLETE' => 'Incompleto',
        _ => status,
      };
}