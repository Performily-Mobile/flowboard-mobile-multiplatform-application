import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/core/session/user_role.dart';
import 'package:flowboard/features/iam/application/session/session_manager.dart';
import 'package:flowboard/features/iam/domain/entity/auth_session.dart';

/// Tells which employee uses the app and with which role, read from the session of IAM.
///
/// The last known values are kept, so a screen that is still closing after the sign out does not
/// fail; the app shows the login as soon as the session ends.
class CurrentEmployeeProvider {
  /// Creates the provider.
  CurrentEmployeeProvider({required this.sessionManager});

  final SessionManager sessionManager;

  EmployeeId? _lastEmployeeId;
  UserRole? _lastRole;

  /// Identifier of the employee using the app; throws [StateError] when nobody signed in.
  EmployeeId currentEmployeeId() {
    _refresh();
    final EmployeeId? employeeId = _lastEmployeeId;
    if (employeeId == null) throw StateError('No hay una sesión iniciada.');
    return employeeId;
  }

  /// Role of the employee using the app; throws [StateError] when nobody signed in.
  UserRole currentRole() {
    _refresh();
    final UserRole? role = _lastRole;
    if (role == null) throw StateError('No hay una sesión iniciada.');
    return role;
  }

  void _refresh() {
    final AuthSession? session = sessionManager.current;
    if (session == null) return;
    _lastEmployeeId = session.employeeId;
    _lastRole = session.isHumanResources ? UserRole.humanResources : UserRole.employee;
  }
}
