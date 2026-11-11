import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/iam/application/session/session_manager.dart';
import 'package:flowboard/features/iam/application/usecase/sign_out_use_case.dart';
import 'package:flowboard/features/iam/domain/entity/auth_session.dart';
import 'package:flowboard/features/iam/domain/valueobject/account_role.dart';
import 'package:flowboard/features/iam/presentation/state/account_security_ui_state.dart';
import 'package:flowboard/features/iam/presentation/viewmodel/iam_error_messages.dart';

/// Handles the account and security screen: profile, preferences and sign out.
class AccountSecurityViewModel extends ViewModel<AccountSecurityUiState> {
  /// Creates the view model with the data of the current session.
  AccountSecurityViewModel({required this.signOut, required SessionManager sessionManager})
      : super(_initialState(sessionManager.current));

  final SignOutUseCase signOut;

  static AccountSecurityUiState _initialState(AuthSession? session) {
    return AccountSecurityUiState(
      username: session?.username ?? '',
      role: session?.role ?? AccountRole.employee,
    );
  }

  /// Opens [dialog]; [AccountDialog.none] closes the open one.
  void openDialog(AccountDialog dialog) =>
      update((AccountSecurityUiState s) => s.copyWith(activeDialog: dialog, errorMessage: null));

  void closeDialog() => openDialog(AccountDialog.none);

  /// Signs out; the app goes back to the login when the session ends.
  Future<void> confirmSignOut() async {
    if (state.isSigningOut) return;
    update((AccountSecurityUiState s) => s.copyWith(activeDialog: AccountDialog.none, isSigningOut: true));
    try {
      await signOut.execute();
    } catch (error) {
      update((AccountSecurityUiState s) => s.copyWith(
            isSigningOut: false,
            errorMessage: iamErrorMessage(error, IamAction.signOut, 'No se pudo cerrar la sesión.'),
          ));
    }
  }
}
