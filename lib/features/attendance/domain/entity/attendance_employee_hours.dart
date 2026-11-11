import 'package:flowboard/features/attendance/domain/entity/attendance_employee.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_hours.dart';

/// Worked and overtime hours of an employee, with the employee data.
class AttendanceEmployeeHours {
  /// Creates the row.
  const AttendanceEmployeeHours({required this.employee, required this.hours});

  final AttendanceEmployee employee;
  final AttendanceHours hours;
}
