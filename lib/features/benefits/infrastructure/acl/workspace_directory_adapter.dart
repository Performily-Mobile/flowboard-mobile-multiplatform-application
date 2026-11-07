import 'package:flowboard/features/benefits/domain/entity/directory_entries.dart';
import 'package:flowboard/features/benefits/domain/repository/workspace_directory.dart';
import 'package:flowboard/features/workspace/application/usecase/get_areas_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_employees_use_case.dart';
import 'package:flowboard/features/workspace/domain/entity/area.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/domain/valueobject/employment_status.dart';

/// Anti-corruption layer toward Workspace.
///
/// It uses the Workspace use cases and translates their entities to the minimum data Benefits
/// needs to assign.
class WorkspaceDirectoryAdapter implements WorkspaceDirectory {
  /// Creates the adapter.
  const WorkspaceDirectoryAdapter({required this.getAreas, required this.getEmployees});

  final GetAreasUseCase getAreas;
  final GetEmployeesUseCase getEmployees;

  @override
  Future<List<AreaOption>> getActiveAreas() async {
    final List<Area> areas = await getAreas.execute(onlyActive: true);
    return areas
        .map((Area area) => AreaOption(id: area.id, name: area.name, activeEmployees: area.activeEmployees))
        .toList();
  }

  @override
  Future<List<EmployeeOption>> getActiveEmployees() async {
    final List<Employee> employees = await getEmployees.execute(status: EmploymentStatus.active);
    return employees
        .map((Employee employee) => EmployeeOption(
              id: employee.id.value,
              name: employee.name.fullName,
              areaName: employee.areaName,
            ))
        .toList();
  }
}
