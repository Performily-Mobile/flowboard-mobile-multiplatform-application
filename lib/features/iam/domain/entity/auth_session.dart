import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/features/iam/domain/valueobject/account_role.dart';

/// Session of the signed-in user: the token sent to the backend and who the user is.
class AuthSession {
  /// Creates the session; throws [ArgumentError] when the token is blank.
  AuthSession({
    required this.token,
    required this.role,
    required this.employeeId,
    required this.mustChangePassword,
    required this.username,
  }) {
    if (token.trim().isEmpty) throw ArgumentError('La sesión no tiene token.');
  }

  /// Token sent in the Authorization header of every request.
  final String token;
  final AccountRole role;
  final EmployeeId employeeId;

  /// True when the user signed in with a temporary password and must create a new one.
  final bool mustChangePassword;

  /// Corporate e-mail used to sign in.
  final String username;

  /// True when the user belongs to the HR staff.
  bool get isHumanResources => role.isHumanResources;

  /// Same session with the token issued after a password change.
  AuthSession withNewPassword(String newToken) => AuthSession(
        token: newToken,
        role: role,
        employeeId: employeeId,
        mustChangePassword: false,
        username: username,
      );
}
