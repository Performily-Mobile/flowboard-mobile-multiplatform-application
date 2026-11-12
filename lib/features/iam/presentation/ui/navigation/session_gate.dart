import 'package:flutter/material.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/features/iam/application/session/session_manager.dart';
import 'package:flowboard/features/iam/domain/entity/auth_session.dart';
import 'package:flowboard/features/iam/presentation/ui/screens/login_screen.dart';
import 'package:flowboard/features/iam/presentation/ui/screens/password_change_screen.dart';

/// Shows the login while nobody is signed in, the mandatory password change after a temporary
/// password, and [child] (the app) once the session is ready.
///
/// When the user or the role changes, the app is built again, so the bottom bar matches the new
/// role. When the session ends, the screens opened above the app are closed.
class SessionGate extends StatefulWidget {
  /// Creates the gate.
  const SessionGate({super.key, required this.child});

  final Widget child;

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  final SessionManager _sessionManager = getIt<SessionManager>();
  String? _shownKey;

  @override
  void initState() {
    super.initState();
    _shownKey = _keyOf(_sessionManager.current);
    _sessionManager.addListener(_onSessionChanged);
  }

  @override
  void dispose() {
    _sessionManager.removeListener(_onSessionChanged);
    super.dispose();
  }

  /// Key of what the gate shows for [session]: nothing, the password change or the app of a user.
  static String? _keyOf(AuthSession? session) {
    if (session == null) return null;
    if (session.mustChangePassword) return 'password-${session.employeeId.value}';
    return 'app-${session.employeeId.value}-${session.role.name}';
  }

  void _onSessionChanged() {
    final String? key = _keyOf(_sessionManager.current);
    if (!mounted || key == _shownKey) return;
    _shownKey = key;
    Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final AuthSession? session = _sessionManager.current;
    if (session == null) return const LoginScreen();
    if (session.mustChangePassword) return const PasswordChangeScreen();
    return KeyedSubtree(key: ValueKey<String?>(_shownKey), child: widget.child);
  }
}
