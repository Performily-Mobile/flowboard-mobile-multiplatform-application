import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/benefits/application/usecase/adjust_vacation_balance_use_case.dart';
import 'package:flowboard/features/benefits/application/usecase/get_vacation_balance_use_case.dart';
import 'package:flowboard/features/benefits/domain/entity/vacation_balance.dart';
import 'package:flowboard/features/benefits/domain/valueobject/adjustment_operation.dart';
import 'package:flowboard/features/benefits/presentation/state/vacation_balance_detail_ui_state.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_formatters.dart';
import 'package:flowboard/features/benefits/presentation/viewmodel/benefits_error_messages.dart';

/// View model of the vacation balance of one employee (MA-63, US42), with its manual adjustment.
class VacationBalanceDetailViewModel extends ViewModel<VacationBalanceDetailUiState> {
  /// Creates the view model; the screen calls [load] with the employee.
  VacationBalanceDetailViewModel({required this.getVacationBalance, required this.adjustVacationBalance})
      : super(const VacationBalanceDetailUiState());

  final GetVacationBalanceUseCase getVacationBalance;
  final AdjustVacationBalanceUseCase adjustVacationBalance;

  static const int _maxReason = 250;

  /// Loads the balance of [employeeId], unless it is already on screen.
  Future<void> load(int employeeId) async {
    if (state.employeeId == employeeId && state.balance != null) return;
    update((VacationBalanceDetailUiState s) => VacationBalanceDetailUiState(employeeId: employeeId, isLoading: true));
    try {
      final VacationBalance balance = await getVacationBalance.execute(employeeId);
      update((VacationBalanceDetailUiState s) => s.copyWith(isLoading: false, balance: balance));
    } catch (error) {
      update((VacationBalanceDetailUiState s) => s.copyWith(
            isLoading: false,
            errorMessage: benefitsMessage(error, BenefitsAction.load, 'No se pudo cargar el saldo.'),
          ));
    }
  }

  /// Loads the balance again after a failure.
  void retry() {
    final int? employeeId = state.employeeId;
    if (employeeId == null) return;
    update((VacationBalanceDetailUiState s) => s.copyWith(employeeId: null));
    load(employeeId);
  }

  /// Opens an empty adjustment form.
  void showAdjustSheet() => update((VacationBalanceDetailUiState s) =>
      s.copyWith(isAdjustSheetVisible: true, adjustmentForm: const AdjustmentForm()));

  /// Closes the adjustment form.
  void dismissAdjustSheet() => update((VacationBalanceDetailUiState s) => s.copyWith(isAdjustSheetVisible: false));

  /// Chooses between adding and deducting days.
  void onOperationChange(AdjustmentOperation operation) => update((VacationBalanceDetailUiState s) => s.copyWith(
        adjustmentForm: s.adjustmentForm.copyWith(operation: operation, daysError: null, errorMessage: null),
      ));

  /// Updates the days keeping only digits and a single decimal point.
  void onDaysChange(String value) {
    final String clean = value.replaceAll(RegExp(r'[^0-9.]'), '');
    if ('.'.allMatches(clean).length > 1) return;
    update((VacationBalanceDetailUiState s) => s.copyWith(
          adjustmentForm: s.adjustmentForm.copyWith(days: clean, daysError: null, errorMessage: null),
        ));
  }

  /// Updates the reason, up to 250 characters.
  void onReasonChange(String value) => update((VacationBalanceDetailUiState s) => s.copyWith(
        adjustmentForm: s.adjustmentForm.copyWith(
          reason: value.length > _maxReason ? value.substring(0, _maxReason) : value,
          reasonError: null,
        ),
      ));

  /// Saves the manual adjustment.
  ///
  /// The rules (quantity, reason, enough balance) are validated by the use case. The answer of the
  /// POST lacks names (employee, area and movement authors), so the balance is fetched again and, if
  /// that fails, the names are completed from the previous balance. Validation errors are flagged on
  /// their field; any other error is shown below the form.
  Future<void> saveAdjustment() async {
    final VacationBalance? balance = state.balance;
    final AdjustmentForm form = state.adjustmentForm;
    if (balance == null || form.isSaving) return;
    final double? days = double.tryParse(form.days);
    if (days == null) {
      update((VacationBalanceDetailUiState s) =>
          s.copyWith(adjustmentForm: form.copyWith(daysError: 'Ingresa una cantidad válida.')));
      return;
    }
    update((VacationBalanceDetailUiState s) => s.copyWith(
          adjustmentForm: form.copyWith(isSaving: true, daysError: null, reasonError: null, errorMessage: null),
        ));
    try {
      final VacationBalance adjusted = await adjustVacationBalance.execute(balance, form.operation, days, form.reason);
      VacationBalance? refreshed;
      try {
        refreshed = await getVacationBalance.execute(balance.employeeId);
      } catch (_) {
        refreshed = null;
      }
      final VacationBalance updated = refreshed ?? _withKnownNames(adjusted, balance);
      final double signed = form.operation == AdjustmentOperation.add ? days : -days;
      update((VacationBalanceDetailUiState s) => s.copyWith(
            balance: updated,
            isAdjustSheetVisible: false,
            adjustmentForm: s.adjustmentForm.copyWith(isSaving: false),
            snackbarMessage: 'Ajuste guardado: ${BenefitsFormatters.signedDays(signed)}. '
                'Disponibles: ${BenefitsFormatters.number(updated.availableDays)}.',
          ));
    } catch (error) {
      final String message = benefitsMessage(error, BenefitsAction.adjust, 'No se pudo guardar el ajuste.');
      final AdjustmentField? field = error is AdjustmentValidationError ? error.field : null;
      update((VacationBalanceDetailUiState s) => s.copyWith(
            adjustmentForm: s.adjustmentForm.copyWith(
              isSaving: false,
              daysError: field == AdjustmentField.days ? message : null,
              reasonError: field == AdjustmentField.reason ? message : null,
              errorMessage: field == null ? message : null,
            ),
          ));
    }
  }

  /// Clears the snackbar message once it was shown.
  void onSnackbarShown() => update((VacationBalanceDetailUiState s) => s.copyWith(snackbarMessage: null));

  VacationBalance _withKnownNames(VacationBalance adjusted, VacationBalance previous) {
    final Map<int, String?> authors = <int, String?>{
      for (final VacationMovement movement in previous.movements) movement.id: movement.authorName,
    };
    return adjusted.copyWith(
      employeeName: adjusted.employeeName ?? previous.employeeName,
      areaName: adjusted.areaName ?? previous.areaName,
      movements: adjusted.movements
          .map((VacationMovement movement) => movement.withAuthor(movement.authorName ?? authors[movement.id]))
          .toList(),
    );
  }
}
