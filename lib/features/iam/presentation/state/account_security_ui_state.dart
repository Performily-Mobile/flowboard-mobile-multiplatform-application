import 'package:flowboard/features/iam/domain/valueobject/account_role.dart';
import 'package:flowboard/features/iam/presentation/ui/components/iam_labels.dart';

const Object _keep = Object();

/// Dialog open in the account and security screen.
enum AccountDialog { none, signOut, language, notifications }

/// State of the account and security screen.
class AccountSecurityUiState {
  /// Creates the state.
  const AccountSecurityUiState({
    this.username = '',
    this.role = AccountRole.employee,
    this.activeDialog = AccountDialog.none,
    this.isSigningOut = false,
    this.errorMessage,
  });

  /// Corporate e-mail of the signed-in user.
  final String username;
  final AccountRole role;
  final AccountDialog activeDialog;
  final bool isSigningOut;
  final String? errorMessage;

  /// Name shown in the profile card, built from the e-mail.
  String get displayName => displayNameFromEmail(username);

  /// Initials shown in the avatar.
  String get initials => initialsOf(displayName);

  /// True when the user can manage the accounts of the employees.
  bool get canManageAccounts => role.isHumanResources;

  /// Copy with the given values replaced.
  AccountSecurityUiState copyWith({
    AccountDialog? activeDialog,
    bool? isSigningOut,
    Object? errorMessage = _keep,
  }) {
    return AccountSecurityUiState(
      username: username,
      role: role,
      activeDialog: activeDialog ?? this.activeDialog,
      isSigningOut: isSigningOut ?? this.isSigningOut,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
    );
  }
}
