import 'package:flowboard/features/iam/application/session/session_manager.dart';
import 'package:flowboard/features/iam/domain/entity/auth_session.dart';
import 'package:flowboard/features/iam/domain/repository/iam_repository.dart';

/// Signs in with the corporate e-mail and the password, and starts the session.
class SignInUseCase {
  /// Creates the use case.
  const SignInUseCase({required this.repository, required this.sessionManager});

  final IamRepository repository;
  final SessionManager sessionManager;

  /// Signs in; throws [ArgumentError] when the e-mail or the password is blank.
  Future<AuthSession> execute({required String username, required String password}) async {
    final String email = username.trim();
    if (email.isEmpty || password.isEmpty) {
      throw ArgumentError('Ingresa tu correo y tu contraseña.');
    }
    final AuthSession session = await repository.signIn(username: email, password: password);
    await sessionManager.start(session);
    return session;
  }
}
