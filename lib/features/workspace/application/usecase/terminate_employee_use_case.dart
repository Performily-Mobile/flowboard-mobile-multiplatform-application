import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/domain/repository/employee_repository.dart';
import 'package:flowboard/features/workspace/domain/valueobject/termination_details.dart';

/// Registers the termination of an employee.
class TerminateEmployeeUseCase {
  /// Creates the use case.
  const TerminateEmployeeUseCase({required this.repository});

  final EmployeeRepository repository;

  /// Terminates [id] with the given [termination] details.
  Future<Employee> execute(EmployeeId id, TerminationDetails termination) {
    return repository.terminate(id, termination);
  }
}
