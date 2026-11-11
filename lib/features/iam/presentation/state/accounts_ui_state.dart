import 'package:flowboard/features/iam/domain/entity/account.dart';

const Object _keep = Object();

/// State of the accounts screen of the HR staff.
class AccountsUiState {
  /// Creates the state.
  const AccountsUiState({
    this.viewerEmployeeId = 0,
    this.isLoading = false,
    this.accounts = const <Account>[],
    this.errorMessage,
    this.roleCandidate,
    this.resetCandidate,
    this.temporaryPassword,
    this.isProcessing = false,
    this.snackbarMessage,
  });

  /// Employee of the signed-in user; their own account cannot be managed from here.
  final int viewerEmployeeId;
  final bool isLoading;
  final List<Account> accounts;
  final String? errorMessage;

  /// Account whose role is being chosen.
  final Account? roleCandidate;

  /// Account whose password reset is being confirmed.
  final Account? resetCandidate;

  /// Temporary password to show once; it is not stored anywhere.
  final String? temporaryPassword;
  final bool isProcessing;
  final String? snackbarMessage;

  /// True when [account] belongs to the signed-in user.
  bool isOwnAccount(Account account) => account.employeeId.value == viewerEmployeeId;

  /// True when the role and the password of [account] can be managed.
  bool canManage(Account account) => account.canBeManaged && !isOwnAccount(account);

  /// Copy with the given values replaced.
  AccountsUiState copyWith({
    bool? isLoading,
    List<Account>? accounts,
    Object? errorMessage = _keep,
    Object? roleCandidate = _keep,
    Object? resetCandidate = _keep,
    Object? temporaryPassword = _keep,
    bool? isProcessing,
    Object? snackbarMessage = _keep,
  }) {
    return AccountsUiState(
      viewerEmployeeId: viewerEmployeeId,
      isLoading: isLoading ?? this.isLoading,
      accounts: accounts ?? this.accounts,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
      roleCandidate: identical(roleCandidate, _keep) ? this.roleCandidate : roleCandidate as Account?,
      resetCandidate: identical(resetCandidate, _keep) ? this.resetCandidate : resetCandidate as Account?,
      temporaryPassword:
          identical(temporaryPassword, _keep) ? this.temporaryPassword : temporaryPassword as String?,
      isProcessing: isProcessing ?? this.isProcessing,
      snackbarMessage: identical(snackbarMessage, _keep) ? this.snackbarMessage : snackbarMessage as String?,
    );
  }
}
