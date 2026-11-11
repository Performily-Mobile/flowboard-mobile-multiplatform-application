import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/features/iam/domain/entity/auth_session.dart';
import 'package:flowboard/features/iam/domain/repository/session_store.dart';
import 'package:flowboard/features/iam/infrastructure/mapper/iam_mapper.dart';

/// Keeps the session encrypted on the device (Keystore on Android, Keychain on iOS).
class SecureSessionStore implements SessionStore {
  /// Creates the store.
  const SecureSessionStore({required this.storage});

  final FlutterSecureStorage storage;

  static const String _key = 'flowboard.session';

  @override
  Future<AuthSession?> read() async {
    try {
      final String? raw = await storage.read(key: _key);
      if (raw == null) return null;
      final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
      return AuthSession(
        token: json['token'] as String,
        role: IamMapper.roleFromApi(json['role'] as String),
        employeeId: EmployeeId((json['employeeId'] as num).toInt()),
        mustChangePassword: json['mustChangePassword'] as bool? ?? false,
        username: json['username'] as String? ?? '',
      );
    } catch (_) {
      // A session that cannot be read is discarded and the user signs in again.
      await _deleteQuietly();
      return null;
    }
  }

  @override
  Future<void> save(AuthSession session) {
    final String raw = jsonEncode(<String, dynamic>{
      'token': session.token,
      'role': IamMapper.roleToApi(session.role),
      'employeeId': session.employeeId.value,
      'mustChangePassword': session.mustChangePassword,
      'username': session.username,
    });
    return storage.write(key: _key, value: raw);
  }

  @override
  Future<void> clear() => storage.delete(key: _key);

  Future<void> _deleteQuietly() async {
    try {
      await storage.delete(key: _key);
    } catch (_) {
      // Nothing else can be done; the next save replaces the value.
    }
  }
}
