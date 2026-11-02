import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/features/workspace/domain/entity/job_assignment.dart';
import 'package:flowboard/features/workspace/domain/repository/employee_repository.dart';

/// Moves an employee to another area and position.
class AssignJobUseCase {
  /// Creates the use case.
  const AssignJobUseCase({required this.repository});

  final EmployeeRepository repository;

  /// Assigns [positionId] of [areaId] to the employee [id] from [effectiveDate].
  Future<JobAssignment> execute(EmployeeId id, int areaId, int positionId, DateTime effectiveDate) {
    return repository.assignJob(id, areaId, positionId, effectiveDate);
  }
}
