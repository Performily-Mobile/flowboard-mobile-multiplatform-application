import 'package:flowboard/features/iam/application/session/session_manager.dart';
import 'package:flowboard/features/iam/domain/repository/iam_repository.dart';

/// Signs out: revokes the token on the backend and ends the session on the device.
class SignOutUseCase {
  /// Creates the use case.
  const SignOutUseCase({required this.repository, required this.sessionManager});

  final IamRepository repository;
  final SessionManager sessionManager;

  /// Signs out; the session always ends on the device, even when the backend cannot be reached.
  Future<void> execute() async {
    try {
      await repository.signOut();
    } on Exception {
      // The token expires by itself on the backend; the device must not keep it.
    } finally {
      await sessionManager.end();
    }
  }
}
