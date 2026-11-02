import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/domain/repository/employee_repository.dart';

/// Lists the direct reports of an employee.
class GetSubordinatesUseCase {
  /// Creates the use case.
  const GetSubordinatesUseCase({required this.repository});

  final EmployeeRepository repository;

  /// Direct reports of [id] sorted by "Last, First"; only the active ones when [onlyActive] is true.
  Future<List<Employee>> execute(EmployeeId id, {bool onlyActive = true}) async {
    final List<Employee> employees = await repository.getSubordinates(id);
    return employees.where((Employee employee) => !onlyActive || employee.isActive).toList()
      ..sort((Employee a, Employee b) => a.name.sortableName.compareTo(b.name.sortableName));
  }
}
