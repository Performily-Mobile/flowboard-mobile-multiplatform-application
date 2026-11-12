import 'package:flowboard/features/payroll/domain/entity/payroll_area.dart';
import 'package:flowboard/features/payroll/domain/entity/payroll_employee.dart';
import 'package:flowboard/features/payroll/domain/repository/payroll_employee_directory.dart';
import 'package:flowboard/features/workspace/application/usecase/get_areas_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_employees_use_case.dart';
import 'package:flowboard/features/workspace/domain/entity/area.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';

/// Anti-corruption layer toward Workspace.
///
/// It uses the Workspace use cases and translates their entities to the minimum data Payroll needs:
/// the name and area of the owner of each payslip. Employees are kept one minute in memory, because
/// every list of payslips asks for them.
class WorkspacePayrollEmployeeDirectory implements PayrollEmployeeDirectory {
  /// Creates the adapter.
  WorkspacePayrollEmployeeDirectory({required this.getAreasUseCase, required this.getEmployeesUseCase});

  final GetAreasUseCase getAreasUseCase;
  final GetEmployeesUseCase getEmployeesUseCase;

  static const Duration _cacheDuration = Duration(minutes: 1);

  List<PayrollEmployee>? _cachedEmployees;
  DateTime _cachedAt = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  Future<List<PayrollEmployee>> getEmployees() async {
    final DateTime now = DateTime.now();
    final List<PayrollEmployee>? cached = _cachedEmployees;
    if (cached != null && now.difference(_cachedAt) < _cacheDuration) return cached;
    final List<Employee> employees = await getEmployeesUseCase.execute();
    final List<PayrollEmployee> result = employees
        .map((Employee employee) => PayrollEmployee(
              id: employee.id,
              firstName: employee.name.firstName.trim(),
              lastName: employee.name.lastName.trim(),
              areaId: employee.areaId,
            ))
        .toList();
    _cachedEmployees = result;
    _cachedAt = now;
    return result;
  }

  @override
  Future<List<PayrollArea>> getAreas() async {
    final List<Area> areas = await getAreasUseCase.execute();
    return areas.map((Area area) => PayrollArea(id: area.id, name: area.name, active: area.active)).toList();
  }
}
