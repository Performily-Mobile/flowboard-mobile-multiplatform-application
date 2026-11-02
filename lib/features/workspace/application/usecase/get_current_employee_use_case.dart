import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/domain/repository/employee_repository.dart';

/// Gets the employee who uses the app.
class GetCurrentEmployeeUseCase {
  /// Creates the use case.
  const GetCurrentEmployeeUseCase({required this.currentEmployeeProvider, required this.repository});

  final CurrentEmployeeProvider currentEmployeeProvider;
  final EmployeeRepository repository;

  /// Employee of the current session.
  Future<Employee> execute() => repository.getEmployeeById(currentEmployeeProvider.currentEmployeeId());
}
