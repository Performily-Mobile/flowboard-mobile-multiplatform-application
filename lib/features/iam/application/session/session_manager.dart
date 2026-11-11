import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flowboard/features/iam/domain/entity/auth_session.dart';
import 'package:flowboard/features/iam/domain/repository/session_store.dart';

/// Holds the session of the signed-in user and tells the app when it starts or ends.
///
/// The app shows the login while there is no session.
class SessionManager extends ChangeNotifier {
  /// Creates the manager without a session; call [restore] to load the saved one.
  SessionManager({required this.store});

  final SessionStore store;

  AuthSession? _current;

  /// Session of the signed-in user, or null when nobody is signed in.
  AuthSession? get current => _current;

  /// True when somebody is signed in.
  bool get isSignedIn => _current != null;

  /// Loads the session saved on the device, if there is one.
  Future<AuthSession?> restore() async {
    _current = await store.read();
    notifyListeners();
    return _current;
  }

  /// Starts [session] and saves it on the device.
  Future<void> start(AuthSession session) async {
    await store.save(session);
    _current = session;
    notifyListeners();
  }

  /// Ends the session and deletes it from the device.
  Future<void> end() async {
    _current = null;
    notifyListeners();
    await store.clear();
  }

  /// Ends the session signed with [token] because the backend no longer accepts it.
  ///
  /// A token of an older session is ignored, so a late answer cannot close a newer session.
  void expire(String token) {
    if (_current?.token != token) return;
    unawaited(end());
  }
}
