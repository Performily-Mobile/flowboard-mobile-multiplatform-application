import 'package:flowboard/features/attendance/domain/entity/attendance_area_summary.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_employee.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_totals.dart';

/// Attendance of an area in a period: its totals, its employees and their records.
class AreaAttendanceReport {
  /// Creates the report.
  const AreaAttendanceReport({required this.summary, required this.employees, required this.records});

  final AttendanceAreaSummary summary;

  /// Active employees of the area, sorted by name.
  final List<AttendanceEmployee> employees;

  /// Records of the area, newest first.
  final List<AttendanceRecord> records;

  /// Records of the employee [employeeId].
  List<AttendanceRecord> recordsOf(int employeeId) {
    return records.where((AttendanceRecord record) => record.employeeId == employeeId).toList();
  }

  /// Totals of the employee [employeeId].
  AttendanceTotals totalsOf(int employeeId) => AttendanceTotals.of(recordsOf(employeeId));
}
