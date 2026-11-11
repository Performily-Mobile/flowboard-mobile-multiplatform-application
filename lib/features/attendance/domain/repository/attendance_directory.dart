import 'package:flowboard/features/attendance/domain/entity/attendance_area.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_employee.dart';

/// Areas and employees of the company, read from the Workspace context.
abstract class AttendanceDirectory {
  /// Active areas, sorted by name.
  Future<List<AttendanceArea>> getAreas();

  /// Every employee, including the ones that left, so old records still show a name.
  Future<List<AttendanceEmployee>> getEmployees();
}
