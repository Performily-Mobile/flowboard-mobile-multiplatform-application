import 'package:flowboard/features/payroll/domain/entity/payroll_area.dart';
import 'package:flowboard/features/payroll/domain/entity/payroll_employee.dart';

/// What Payroll needs from Workspace: the name and area of the employees and the areas.
///
/// It is the anti-corruption layer: Payroll never uses the Workspace entities directly.
abstract class PayrollEmployeeDirectory {
  /// Employees of the organization.
  Future<List<PayrollEmployee>> getEmployees();

  /// Areas of the organization.
  Future<List<PayrollArea>> getAreas();
}
