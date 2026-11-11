import 'package:flowboard/features/attendance/domain/entity/attendance_employee.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_page.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/repository/attendance_directory.dart';

/// Completes the attendance records with the names and areas of the employees.
///
/// When Workspace fails the records are returned as they are, with the employee number as name.
class AttendancePeopleResolver {
  /// Creates the resolver.
  const AttendancePeopleResolver({required this.directory});

  final AttendanceDirectory directory;

  /// Records of [records] with their employees, newest first.
  Future<List<AttendanceRecord>> resolveAll(List<AttendanceRecord> records) async {
    if (records.isEmpty) return records;
    final Map<int, AttendanceEmployee> people = await _people();
    return records.map((AttendanceRecord record) => record.withEmployee(people[record.employeeId])).toList()
      ..sort(AttendanceRecord.newestFirst);
  }

  /// Records of [page] with their employees.
  Future<AttendancePage> resolvePage(AttendancePage page) async => page.withRecords(await resolveAll(page.records));

  /// Employee [employeeId]; null when it is unknown or Workspace fails.
  Future<AttendanceEmployee?> employee(int employeeId) async => (await _people())[employeeId];

  /// Active employees of the area [areaId], sorted by name; throws when Workspace fails.
  Future<List<AttendanceEmployee>> employeesOfArea(int areaId) async {
    final List<AttendanceEmployee> employees = await directory.getEmployees();
    return employees.where((AttendanceEmployee e) => e.areaId == areaId && e.isActive).toList()
      ..sort((AttendanceEmployee a, AttendanceEmployee b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  Future<Map<int, AttendanceEmployee>> _people() async {
    try {
      final List<AttendanceEmployee> employees = await directory.getEmployees();
      return <int, AttendanceEmployee>{for (final AttendanceEmployee employee in employees) employee.id: employee};
    } catch (_) {
      return <int, AttendanceEmployee>{};
    }
  }
}
