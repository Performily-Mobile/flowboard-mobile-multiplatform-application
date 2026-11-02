import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/domain/repository/employee_repository.dart';

/// Removes the direct manager of an employee.
class RemoveDirectManagerUseCase {
  /// Creates the use case.
  const RemoveDirectManagerUseCase({required this.repository});

  final EmployeeRepository repository;

  /// Leaves [id] without a direct manager.
  Future<Employee> execute(EmployeeId id) => repository.removeDirectManager(id);
}
