import 'package:flowboard/features/attendance/domain/entity/attendance_employee.dart';
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
    this.employeeName,
    this.areaName,
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

  /// Name of the employee, read from Workspace; null until it is known.
  final String? employeeName;

  /// Area of the employee, read from Workspace; null until it is known.
  final String? areaName;

  /// Orders records from the newest work day to the oldest.
  static int newestFirst(AttendanceRecord a, AttendanceRecord b) => b.workDate.compareTo(a.workDate);

  /// True when the employee can justify this day.
  bool get canBeJustified => id != null && status.canBeJustified;

  /// Name to show, with the employee number when the name is unknown.
  String get displayName => employeeName ?? 'Colaborador #$employeeId';

  /// True when the record belongs to [day].
  bool isOn(DateTime day) => workDate.year == day.year && workDate.month == day.month && workDate.day == day.day;

  /// Copy with the name and the area of [employee]; the same record when it is null.
  AttendanceRecord withEmployee(AttendanceEmployee? employee) {
    if (employee == null) return this;
    return AttendanceRecord(
      id: id,
      employeeId: employeeId,
      workDate: workDate,
      checkIn: checkIn,
      checkOut: checkOut,
      workedHours: workedHours,
      overtimeHours: overtimeHours,
      status: status,
      justificationReason: justificationReason,
      employeeName: employee.name,
      areaName: employee.areaName,
    );
  }
}
