import 'package:flowboard/features/iam/application/session/session_manager.dart';
import 'package:flowboard/features/iam/domain/entity/auth_session.dart';

/// Loads the session saved on the device when the app opens.
class RestoreSessionUseCase {
  /// Creates the use case.
  const RestoreSessionUseCase({required this.sessionManager});

  final SessionManager sessionManager;

  /// Saved session, or null when the user has to sign in.
  Future<AuthSession?> execute() => sessionManager.restore();
}
