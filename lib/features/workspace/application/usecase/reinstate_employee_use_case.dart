import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/domain/repository/employee_repository.dart';

/// Brings a terminated employee back.
class ReinstateEmployeeUseCase {
  /// Creates the use case.
  const ReinstateEmployeeUseCase({required this.repository});

  final EmployeeRepository repository;

  /// Reinstates [id] in [positionId] of [areaId] from [reinstatementDate].
  Future<Employee> execute(EmployeeId id, int areaId, int positionId, DateTime reinstatementDate) {
    return repository.reinstate(id, areaId, positionId, reinstatementDate);
  }
}
