import 'package:flowboard/features/iam/domain/entity/auth_session.dart';

/// Keeps the session on the device, so the user stays signed in after closing the app.
abstract class SessionStore {
  /// Saved session, or null when there is none or it cannot be read.
  Future<AuthSession?> read();

  /// Saves [session], replacing the previous one.
  Future<void> save(AuthSession session);

  /// Deletes the saved session.
  Future<void> clear();
}
