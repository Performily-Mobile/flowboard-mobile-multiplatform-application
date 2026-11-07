import 'package:flowboard/features/benefits/domain/entity/directory_entries.dart';

/// What Benefits needs from Workspace to assign: active areas and employees.
///
/// It is the anti-corruption layer: Benefits never uses the Workspace entities directly.
abstract class WorkspaceDirectory {
  /// Active areas of the organization.
  Future<List<AreaOption>> getActiveAreas();

  /// Active employees of the organization.
  Future<List<EmployeeOption>> getActiveEmployees();
}
