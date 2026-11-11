import 'package:flowboard/features/iam/domain/valueobject/password_policy.dart';

const Object _keep = Object();

/// Password field of the change password screen.
enum PasswordField { current, newPassword, confirmation }

/// State of the change password screen.
class PasswordChangeUiState {
  /// Creates the state.
  const PasswordChangeUiState({
    this.isMandatory = false,
    this.currentPassword = '',
    this.newPassword = '',
    this.confirmation = '',
    this.visibleFields = const <PasswordField>{},
    this.isSaving = false,
    this.errorMessage,
    this.resultMessage,
  });

  /// True when the user signed in with a temporary password and cannot skip the change.
  final bool isMandatory;
  final String currentPassword;
  final String newPassword;
  final String confirmation;

  /// Fields whose text is shown instead of hidden.
  final Set<PasswordField> visibleFields;
  final bool isSaving;
  final String? errorMessage;

  /// When set, the password was changed and the screen closes with this message.
  final String? resultMessage;

  bool get hasMinLength => PasswordPolicy.hasMinLength(newPassword);
  bool get hasUpperAndLowerCase => PasswordPolicy.hasUpperAndLowerCase(newPassword);
  bool get hasDigit => PasswordPolicy.hasDigit(newPassword);
  bool get hasSymbol => PasswordPolicy.hasSymbol(newPassword);

  /// True when the confirmation was typed and differs from the new password.
  bool get confirmationMismatch => confirmation.isNotEmpty && confirmation != newPassword;

  /// True when every field is filled and no request is running.
  bool get canSubmit =>
      currentPassword.isNotEmpty && newPassword.isNotEmpty && confirmation.isNotEmpty && !isSaving;

  /// True when the text of [field] is shown.
  bool isVisible(PasswordField field) => visibleFields.contains(field);

  /// Copy with the given values replaced.
  PasswordChangeUiState copyWith({
    String? currentPassword,
    String? newPassword,
    String? confirmation,
    Set<PasswordField>? visibleFields,
    bool? isSaving,
    Object? errorMessage = _keep,
    Object? resultMessage = _keep,
  }) {
    return PasswordChangeUiState(
      isMandatory: isMandatory,
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmation: confirmation ?? this.confirmation,
      visibleFields: visibleFields ?? this.visibleFields,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
      resultMessage: identical(resultMessage, _keep) ? this.resultMessage : resultMessage as String?,
    );
  }
}
