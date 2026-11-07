import 'package:flowboard/features/benefits/domain/entity/vacation_balance.dart';
import 'package:flowboard/features/benefits/domain/valueobject/adjustment_operation.dart';

const Object _keep = Object();

/// Values of the "Ajustar saldo" sheet (MA-63).
class AdjustmentForm {
  /// Creates the form.
  const AdjustmentForm({
    this.operation = AdjustmentOperation.add,
    this.days = '',
    this.reason = '',
    this.daysError,
    this.reasonError,
    this.errorMessage,
    this.isSaving = false,
  });

  final AdjustmentOperation operation;
  final String days;
  final String reason;
  final String? daysError;
  final String? reasonError;
  final String? errorMessage;
  final bool isSaving;

  /// Copy with the given values replaced.
  AdjustmentForm copyWith({
    AdjustmentOperation? operation,
    String? days,
    String? reason,
    Object? daysError = _keep,
    Object? reasonError = _keep,
    Object? errorMessage = _keep,
    bool? isSaving,
  }) {
    return AdjustmentForm(
      operation: operation ?? this.operation,
      days: days ?? this.days,
      reason: reason ?? this.reason,
      daysError: identical(daysError, _keep) ? this.daysError : daysError as String?,
      reasonError: identical(reasonError, _keep) ? this.reasonError : reasonError as String?,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

/// State of the vacation balance of one employee, seen by HR (MA-63).
class VacationBalanceDetailUiState {
  /// Creates the state.
  const VacationBalanceDetailUiState({
    this.employeeId,
    this.isLoading = false,
    this.balance,
    this.errorMessage,
    this.isAdjustSheetVisible = false,
    this.adjustmentForm = const AdjustmentForm(),
    this.snackbarMessage,
  });

  final int? employeeId;
  final bool isLoading;
  final VacationBalance? balance;
  final String? errorMessage;
  final bool isAdjustSheetVisible;
  final AdjustmentForm adjustmentForm;
  final String? snackbarMessage;

  /// Copy with the given values replaced.
  VacationBalanceDetailUiState copyWith({
    Object? employeeId = _keep,
    bool? isLoading,
    Object? balance = _keep,
    Object? errorMessage = _keep,
    bool? isAdjustSheetVisible,
    AdjustmentForm? adjustmentForm,
    Object? snackbarMessage = _keep,
  }) {
    return VacationBalanceDetailUiState(
      employeeId: identical(employeeId, _keep) ? this.employeeId : employeeId as int?,
      isLoading: isLoading ?? this.isLoading,
      balance: identical(balance, _keep) ? this.balance : balance as VacationBalance?,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
      isAdjustSheetVisible: isAdjustSheetVisible ?? this.isAdjustSheetVisible,
      adjustmentForm: adjustmentForm ?? this.adjustmentForm,
      snackbarMessage: identical(snackbarMessage, _keep) ? this.snackbarMessage : snackbarMessage as String?,
    );
  }
}
