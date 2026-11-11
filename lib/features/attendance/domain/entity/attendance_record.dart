import 'package:flowboard/features/attendance/domain/valueobject/attendance_status.dart';

/// Attendance of an employee on one work day.
class AttendanceRecord {
  /// Creates the record.
  const AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.workDate,
    required this.checkIn,
    required this.checkOut,
    required this.workedHours,
    required this.overtimeHours,
    required this.status,
    this.justificationReason,
  });

  /// Identifier of the record; null for a day that was not saved yet.
  final int? id;
  final int employeeId;
  final DateTime workDate;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final double workedHours;
  final double overtimeHours;
  final AttendanceStatus status;
  final String? justificationReason;

  /// True when the employee can justify this day.
  bool get canBeJustified => id != null && status.canBeJustified;
}
