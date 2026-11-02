import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/domain/repository/employee_repository.dart';

/// Gets one employee.
class GetEmployeeByIdUseCase {
  /// Creates the use case.
  const GetEmployeeByIdUseCase({required this.repository});

  final EmployeeRepository repository;

  /// Employee [id].
  Future<Employee> execute(EmployeeId id) => repository.getEmployeeById(id);
}
