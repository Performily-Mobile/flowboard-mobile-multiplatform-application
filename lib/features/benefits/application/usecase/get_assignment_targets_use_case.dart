import 'package:flowboard/features/benefits/domain/entity/directory_entries.dart';
import 'package:flowboard/features/benefits/domain/repository/workspace_directory.dart';

/// Active areas and employees offered by the assignment form (MA-61), sorted by name.
class GetAssignmentTargetsUseCase {
  /// Creates the use case.
  const GetAssignmentTargetsUseCase({required this.directory});

  final WorkspaceDirectory directory;

  /// Active areas sorted by name.
  Future<List<AreaOption>> areas() async {
    final List<AreaOption> areas = await directory.getActiveAreas();
    return areas..sort((AreaOption a, AreaOption b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  /// Active employees sorted by name.
  Future<List<EmployeeOption>> employees() async {
    final List<EmployeeOption> employees = await directory.getActiveEmployees();
    return employees
      ..sort((EmployeeOption a, EmployeeOption b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }
}
