import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/features/iam/domain/valueobject/account_role.dart';
import 'package:flowboard/features/iam/domain/valueobject/account_status.dart';

/// Account of an employee, managed by the HR staff.
class Account {
  /// Creates the account.
  const Account({
    required this.id,
    required this.employeeId,
    required this.username,
    required this.role,
    required this.status,
    required this.mustChangePassword,
  });

  final int id;
  final EmployeeId employeeId;

  /// Corporate e-mail used to sign in.
  final String username;
  final AccountRole role;
  final AccountStatus status;

  /// True while the account still uses a temporary password.
  final bool mustChangePassword;

  /// True when the role can be changed and the password reset.
  bool get canBeManaged => status.isActive;
}
