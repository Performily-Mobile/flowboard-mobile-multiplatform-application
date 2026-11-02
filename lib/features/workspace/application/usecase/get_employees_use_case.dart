import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/domain/repository/employee_repository.dart';
import 'package:flowboard/features/workspace/domain/valueobject/employment_status.dart';

/// Searches employees and sorts them by last name.
class GetEmployeesUseCase {
  /// Creates the use case.
  const GetEmployeesUseCase({required this.repository});

  final EmployeeRepository repository;

  /// Employees that match [search] and the filters, sorted by "Last, First".
  Future<List<Employee>> execute({String? search, int? areaId, EmploymentStatus? status, int? positionId}) async {
    final String? query = search?.trim();
    final List<Employee> employees = await repository.getEmployees(
      search: query == null || query.isEmpty ? null : query,
      areaId: areaId,
      status: status,
      positionId: positionId,
    );
    return employees
      ..sort((Employee a, Employee b) =>
          a.name.sortableName.toLowerCase().compareTo(b.name.sortableName.toLowerCase()));
  }
}
