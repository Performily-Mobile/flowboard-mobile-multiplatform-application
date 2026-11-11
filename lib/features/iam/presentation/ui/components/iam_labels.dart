import 'package:flowboard/features/iam/domain/valueobject/account_role.dart';
import 'package:flowboard/features/iam/domain/valueobject/account_status.dart';

/// Spanish label of a role.
extension AccountRoleLabel on AccountRole {
  /// Label shown in the screens, for example "Personal de RR. HH.".
  String get label => switch (this) {
        AccountRole.humanResources => 'Personal de RR. HH.',
        AccountRole.employee => 'Colaborador',
      };
}

/// Spanish label of an account status.
extension AccountStatusLabel on AccountStatus {
  /// Label shown in the screens, for example "Activa".
  String get label => switch (this) {
        AccountStatus.active => 'Activa',
        AccountStatus.disabled => 'Deshabilitada',
      };
}

/// Readable name built from the e-mail, for example "luis.gutierrez@..." gives "Luis Gutierrez".
String displayNameFromEmail(String email) {
  final List<String> parts = email
      .split('@')
      .first
      .split(RegExp('[._-]'))
      .where((String part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'Mi cuenta';
  return parts.map((String part) => part[0].toUpperCase() + part.substring(1)).join(' ');
}

/// First letter of up to two words of [name], for example "LG".
String initialsOf(String name) {
  return name
      .split(' ')
      .where((String word) => word.isNotEmpty)
      .take(2)
      .map((String word) => word[0].toUpperCase())
      .join();
}
