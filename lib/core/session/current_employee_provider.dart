import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/core/session/user_role.dart';

/// Tells which employee uses the app and with which role.
///
/// Temporary: while the IAM bounded context (login) does not exist it returns fixed values.
/// To try the employee view, change [_defaultRole] to [UserRole.employee].
class CurrentEmployeeProvider {
  static const int _defaultEmployeeId = 2;
  static const UserRole _defaultRole = UserRole.humanResources;

  /// Identifier of the employee using the app.
  EmployeeId currentEmployeeId() => EmployeeId(_defaultEmployeeId);

  /// Role of the employee using the app.
  UserRole currentRole() => _defaultRole;
}
