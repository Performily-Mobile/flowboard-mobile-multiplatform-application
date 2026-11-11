import 'package:flowboard/features/attendance/domain/entity/attendance_employee.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_totals.dart';

/// Attendance of one employee in a period, seen by the HR staff.
class EmployeeAttendance {
  /// Creates the attendance.
  const EmployeeAttendance({required this.employeeId, required this.employee, required this.records});

  final int employeeId;

  /// Data of the employee; null when Workspace did not answer.
  final AttendanceEmployee? employee;

  /// Records of the period, newest first.
  final List<AttendanceRecord> records;

  /// Name to show, with the employee number when the name is unknown.
  String get displayName => employee?.name ?? 'Colaborador #$employeeId';

  /// Totals of [records].
  AttendanceTotals get totals => AttendanceTotals.of(records);
}
