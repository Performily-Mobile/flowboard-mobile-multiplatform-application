import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/iam/application/session/session_manager.dart';
import 'package:flowboard/features/iam/application/usecase/change_account_role_use_case.dart';
import 'package:flowboard/features/iam/application/usecase/get_accounts_use_case.dart';
import 'package:flowboard/features/iam/application/usecase/reset_account_password_use_case.dart';
import 'package:flowboard/features/iam/domain/entity/account.dart';
import 'package:flowboard/features/iam/domain/valueobject/account_role.dart';
import 'package:flowboard/features/iam/presentation/state/accounts_ui_state.dart';
import 'package:flowboard/features/iam/presentation/ui/components/iam_labels.dart';
import 'package:flowboard/features/iam/presentation/viewmodel/iam_error_messages.dart';

/// Handles the accounts screen of the HR staff: change roles and reset passwords.
class AccountsViewModel extends ViewModel<AccountsUiState> {
  /// Creates the view model.
  AccountsViewModel({
    required this.getAccounts,
    required this.changeAccountRole,
    required this.resetAccountPassword,
    required SessionManager sessionManager,
  }) : super(AccountsUiState(viewerEmployeeId: sessionManager.current?.employeeId.value ?? 0));

  final GetAccountsUseCase getAccounts;
  final ChangeAccountRoleUseCase changeAccountRole;
  final ResetAccountPasswordUseCase resetAccountPassword;

  /// Loads the accounts of every employee.
  Future<void> load() async {
    update((AccountsUiState s) => s.copyWith(isLoading: true, errorMessage: null));
    try {
      final List<Account> accounts = await getAccounts.execute();
      update((AccountsUiState s) => s.copyWith(isLoading: false, accounts: accounts));
    } catch (error) {
      update((AccountsUiState s) => s.copyWith(
            isLoading: false,
            errorMessage: iamErrorMessage(error, IamAction.loadAccounts, 'No se pudieron cargar las cuentas.'),
          ));
    }
  }

  void askRoleChange(Account account) => update((AccountsUiState s) => s.copyWith(roleCandidate: account));

  void askPasswordReset(Account account) => update((AccountsUiState s) => s.copyWith(resetCandidate: account));

  /// Closes the open dialog without changing anything.
  void dismissDialog() => update((AccountsUiState s) => s.copyWith(roleCandidate: null, resetCandidate: null));

  /// Gives [role] to the account being edited.
  Future<void> confirmRoleChange(AccountRole role) async {
    final Account? account = state.roleCandidate;
    if (account == null || state.isProcessing) return;
    update((AccountsUiState s) => s.copyWith(roleCandidate: null, isProcessing: true));
    try {
      final Account updated = await changeAccountRole.execute(account: account, role: role);
      update((AccountsUiState s) => s.copyWith(
            isProcessing: false,
            accounts: <Account>[
              for (final Account item in s.accounts) item.id == updated.id ? updated : item,
            ],
            snackbarMessage: 'Rol actualizado a ${updated.role.label}.',
          ));
    } catch (error) {
      update((AccountsUiState s) => s.copyWith(
            isProcessing: false,
            snackbarMessage: iamErrorMessage(error, IamAction.changeRole, 'No se pudo cambiar el rol.'),
          ));
    }
  }

  /// Resets the password of the account being confirmed and keeps the temporary one to show it.
  Future<void> confirmPasswordReset() async {
    final Account? account = state.resetCandidate;
    if (account == null || state.isProcessing) return;
    update((AccountsUiState s) => s.copyWith(resetCandidate: null, isProcessing: true));
    try {
      final String temporaryPassword = await resetAccountPassword.execute(account);
      update((AccountsUiState s) => s.copyWith(isProcessing: false, temporaryPassword: temporaryPassword));
    } catch (error) {
      update((AccountsUiState s) => s.copyWith(
            isProcessing: false,
            snackbarMessage: iamErrorMessage(error, IamAction.resetPassword, 'No se pudo restablecer la contraseña.'),
          ));
    }
  }

  /// Forgets the temporary password once HR closed it.
  void dismissTemporaryPassword() => update((AccountsUiState s) => s.copyWith(temporaryPassword: null));

  void consumeSnackbar() => update((AccountsUiState s) => s.copyWith(snackbarMessage: null));
}
