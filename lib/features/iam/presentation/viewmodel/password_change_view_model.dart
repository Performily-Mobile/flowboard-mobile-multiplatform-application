import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/iam/application/session/session_manager.dart';
import 'package:flowboard/features/iam/application/usecase/change_password_use_case.dart';
import 'package:flowboard/features/iam/application/usecase/sign_out_use_case.dart';
import 'package:flowboard/features/iam/presentation/state/password_change_ui_state.dart';
import 'package:flowboard/features/iam/presentation/viewmodel/iam_error_messages.dart';

/// Handles the change password screen, both the mandatory change after a temporary password and
/// the change the user starts from the account screen.
class PasswordChangeViewModel extends ViewModel<PasswordChangeUiState> {
  /// Creates the view model; the change is mandatory when the session asks for it.
  PasswordChangeViewModel({
    required this.changePassword,
    required this.signOut,
    required SessionManager sessionManager,
  }) : super(PasswordChangeUiState(isMandatory: sessionManager.current?.mustChangePassword ?? false));

  final ChangePasswordUseCase changePassword;
  final SignOutUseCase signOut;

  void onCurrentPasswordChange(String value) =>
      update((PasswordChangeUiState s) => s.copyWith(currentPassword: value, errorMessage: null));

  void onNewPasswordChange(String value) =>
      update((PasswordChangeUiState s) => s.copyWith(newPassword: value, errorMessage: null));

  void onConfirmationChange(String value) =>
      update((PasswordChangeUiState s) => s.copyWith(confirmation: value, errorMessage: null));

  /// Shows or hides the text of [field].
  void toggleVisibility(PasswordField field) {
    update((PasswordChangeUiState s) {
      final Set<PasswordField> visible = <PasswordField>{...s.visibleFields};
      if (!visible.remove(field)) visible.add(field);
      return s.copyWith(visibleFields: visible);
    });
  }

  /// Saves the new password.
  Future<void> submit() async {
    if (state.isSaving) return;
    if (state.newPassword != state.confirmation) {
      update((PasswordChangeUiState s) => s.copyWith(errorMessage: 'Las contraseñas no coinciden.'));
      return;
    }
    update((PasswordChangeUiState s) => s.copyWith(isSaving: true, errorMessage: null));
    try {
      await changePassword.execute(currentPassword: state.currentPassword, newPassword: state.newPassword);
      update((PasswordChangeUiState s) => s.copyWith(isSaving: false, resultMessage: 'Contraseña actualizada.'));
    } catch (error) {
      update((PasswordChangeUiState s) => s.copyWith(
            isSaving: false,
            errorMessage: iamErrorMessage(error, IamAction.changePassword, 'No se pudo cambiar la contraseña.'),
          ));
    }
  }

  /// Leaves the mandatory change by signing out.
  Future<void> leave() async {
    if (state.isSaving) return;
    update((PasswordChangeUiState s) => s.copyWith(isSaving: true));
    await signOut.execute();
  }

  /// Clears the result once the screen showed it.
  void consumeResult() => update((PasswordChangeUiState s) => s.copyWith(resultMessage: null));
}
