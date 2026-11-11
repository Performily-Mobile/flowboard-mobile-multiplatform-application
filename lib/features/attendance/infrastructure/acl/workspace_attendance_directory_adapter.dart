import 'package:flowboard/features/attendance/domain/entity/attendance_area.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_employee.dart';
import 'package:flowboard/features/attendance/domain/repository/attendance_directory.dart';
import 'package:flowboard/features/workspace/application/usecase/get_areas_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_employees_use_case.dart';
import 'package:flowboard/features/workspace/domain/entity/area.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';

/// Reads the areas and the employees from the Workspace use cases.
///
/// The employees are kept for a few minutes, so moving between sections does not download them
/// again.
class WorkspaceAttendanceDirectoryAdapter implements AttendanceDirectory {
  /// Creates the adapter.
  WorkspaceAttendanceDirectoryAdapter({required this.getAreasUseCase, required this.getEmployeesUseCase});

  final GetAreasUseCase getAreasUseCase;
  final GetEmployeesUseCase getEmployeesUseCase;

  static const Duration _cacheDuration = Duration(minutes: 5);

  List<AttendanceEmployee>? _employees;
  DateTime? _loadedAt;

  @override
  Future<List<AttendanceArea>> getAreas() async {
    final List<Area> areas = await getAreasUseCase.execute(onlyActive: true);
    return areas.map((Area area) => AttendanceArea(id: area.id, name: area.name)).toList()
      ..sort((AttendanceArea a, AttendanceArea b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  @override
  Future<List<AttendanceEmployee>> getEmployees() async {
    final List<AttendanceEmployee>? cached = _employees;
    final DateTime? loadedAt = _loadedAt;
    if (cached != null && loadedAt != null && DateTime.now().difference(loadedAt) < _cacheDuration) {
      return cached;
    }
    final List<Employee> employees = await getEmployeesUseCase.execute();
    final List<AttendanceEmployee> result = employees.map(_toEmployee).toList();
    _employees = result;
    _loadedAt = DateTime.now();
    return result;
  }

  AttendanceEmployee _toEmployee(Employee employee) {
    return AttendanceEmployee(
      id: employee.id.value,
      name: employee.name.fullName,
      areaId: employee.areaId,
      areaName: employee.areaName,
      positionTitle: employee.positionTitle,
      isActive: employee.isActive,
    );
  }
}
