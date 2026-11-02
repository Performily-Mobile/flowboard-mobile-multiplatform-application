import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/domain/repository/employee_repository.dart';

/// Sets the direct manager of an employee.
class AssignDirectManagerUseCase {
  /// Creates the use case.
  const AssignDirectManagerUseCase({required this.repository});

  final EmployeeRepository repository;

  /// Sets [managerId] as the direct manager of [id]; throws [ArgumentError] when both are the
  /// same employee.
  Future<Employee> execute(EmployeeId id, EmployeeId managerId) {
    if (id == managerId) {
      throw ArgumentError('Un colaborador no puede ser su propio jefe directo.');
    }
    return repository.assignDirectManager(id, managerId);
  }
}
