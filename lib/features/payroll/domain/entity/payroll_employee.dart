import 'package:flowboard/core/domain/employee_id.dart';

/// Employee as Payroll needs it (owner of the payslip). It comes from Workspace through the
/// anti-corruption layer; Payroll never changes it.
class PayrollEmployee {
  /// Creates the employee.
  const PayrollEmployee({required this.id, required this.firstName, required this.lastName, required this.areaId});

  final EmployeeId id;
  final String firstName;
  final String lastName;
  final int? areaId;

  /// "Pedro Huamán Quispe".
  String get fullName => '$firstName $lastName'.trim();

  /// "Huamán Quispe, Pedro".
  String get sortableName => lastName.trim().isEmpty ? firstName : '$lastName, $firstName';

  /// "PH".
  String get initials {
    final String first = firstName.trim();
    final String last = lastName.trim();
    return '${first.isEmpty ? '' : first[0]}${last.isEmpty ? '' : last[0]}'.toUpperCase();
  }
}
