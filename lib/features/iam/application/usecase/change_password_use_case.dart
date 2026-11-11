import 'package:flowboard/features/iam/application/session/session_manager.dart';
import 'package:flowboard/features/iam/domain/entity/auth_session.dart';
import 'package:flowboard/features/iam/domain/repository/iam_repository.dart';
import 'package:flowboard/features/iam/domain/valueobject/password_policy.dart';

/// Changes the password of the signed-in user and keeps the session with the new token.
class ChangePasswordUseCase {
  /// Creates the use case.
  const ChangePasswordUseCase({required this.repository, required this.sessionManager});

  final IamRepository repository;
  final SessionManager sessionManager;

  /// Changes the password; throws [ArgumentError] when the new one breaks the [PasswordPolicy]
  /// or equals the current one, and [StateError] when nobody is signed in.
  Future<void> execute({required String currentPassword, required String newPassword}) async {
    final AuthSession? session = sessionManager.current;
    if (session == null) throw StateError('Tu sesión expiró. Vuelve a ingresar.');
    if (currentPassword.isEmpty) throw ArgumentError('Ingresa tu contraseña actual.');
    PasswordPolicy.ensureValid(newPassword);
    if (newPassword == currentPassword) {
      throw ArgumentError('La nueva contraseña debe ser distinta de la actual.');
    }
    final String newToken = await repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    await sessionManager.start(session.withNewPassword(newToken));
  }
}
