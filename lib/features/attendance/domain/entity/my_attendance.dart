import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_totals.dart';
import 'package:flowboard/features/attendance/domain/valueobject/punch_type.dart';

/// Attendance of the signed-in employee: the records of a period and the record of today.
class MyAttendance {
  /// Creates the attendance.
  const MyAttendance({required this.records, required this.today});

  /// Records of the period, newest first.
  final List<AttendanceRecord> records;

  /// Record of today; null when the employee has not punched yet.
  final AttendanceRecord? today;

  /// Totals of [records].
  AttendanceTotals get totals => AttendanceTotals.of(records);

  /// Punch the employee can register now; null when the work day is already closed.
  PunchType? get nextPunch {
    final AttendanceRecord? record = today;
    if (record == null || record.checkIn == null) return PunchType.checkIn;
    if (record.checkOut == null) return PunchType.checkOut;
    return null;
  }
}
