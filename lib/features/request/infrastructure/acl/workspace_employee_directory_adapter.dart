import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/features/request/domain/entity/request_person.dart';
import 'package:flowboard/features/request/domain/repository/request_employee_directory.dart';
import 'package:flowboard/features/workspace/application/usecase/get_employee_by_id_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_employees_use_case.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';

/// Reads the employees from the Workspace use cases and translates them into [RequestPerson].
///
/// The whole list is kept for a few minutes, so loading more pages does not download every
/// employee again.
class WorkspaceEmployeeDirectoryAdapter implements RequestEmployeeDirectory {
  /// Creates the adapter.
  WorkspaceEmployeeDirectoryAdapter({required this.getEmployeeById, required this.getEmployees});

  final GetEmployeeByIdUseCase getEmployeeById;
  final GetEmployeesUseCase getEmployees;

  static const Duration _cacheDuration = Duration(minutes: 5);

  List<RequestPerson>? _people;
  DateTime? _loadedAt;

  @override
  Future<RequestPerson> getPerson(int employeeId) async {
    return _toPerson(await getEmployeeById.execute(EmployeeId(employeeId)));
  }

  @override
  Future<List<RequestPerson>> getPeople() async {
    final List<RequestPerson>? cached = _people;
    final DateTime? loadedAt = _loadedAt;
    if (cached != null && loadedAt != null && DateTime.now().difference(loadedAt) < _cacheDuration) {
      return cached;
    }
    final List<Employee> employees = await getEmployees.execute();
    final List<RequestPerson> people = employees.map(_toPerson).toList();
    _people = people;
    _loadedAt = DateTime.now();
    return people;
  }

  RequestPerson _toPerson(Employee employee) {
    return RequestPerson(
      id: employee.id.value,
      name: employee.name.fullName,
      jobDescription: employee.jobDescription,
      directManagerId: employee.directManagerId?.value,
    );
  }
}
