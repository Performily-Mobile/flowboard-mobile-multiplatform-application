import 'package:flowboard/features/payroll/application/usecase/payslip_entry.dart';
import 'package:flowboard/features/payroll/domain/entity/payroll_area.dart';
import 'package:flowboard/features/payroll/domain/entity/payroll_period.dart';
import 'package:flowboard/features/payroll/domain/valueobject/payment_status.dart';
import 'package:flowboard/features/payroll/presentation/state/payment_sheet_form.dart';

export 'package:flowboard/features/payroll/presentation/state/payment_sheet_form.dart';

const Object _keep = Object();

/// State of the HR payment status screen (MA-69).
class PaymentStatusUiState {
  /// Creates the state; the report starts filtered by pending deposits.
  const PaymentStatusUiState({
    this.periods = const <PayrollPeriod>[],
    this.selectedPeriod,
    this.areas = const <PayrollArea>[],
    this.selectedArea,
    this.selectedStatus = PaymentStatus.pending,
    this.isLoading = false,
    this.entries = const <PayslipEntry>[],
    this.errorMessage,
    this.sheet,
    this.snackbarMessage,
  });

  final List<PayrollPeriod> periods;
  final PayrollPeriod? selectedPeriod;
  final List<PayrollArea> areas;
  final PayrollArea? selectedArea;
  final PaymentStatus? selectedStatus;
  final bool isLoading;
  final List<PayslipEntry> entries;
  final String? errorMessage;
  final PaymentSheetForm? sheet;
  final String? snackbarMessage;

  /// Copy with the given values replaced.
  PaymentStatusUiState copyWith({
    List<PayrollPeriod>? periods,
    Object? selectedPeriod = _keep,
    List<PayrollArea>? areas,
    Object? selectedArea = _keep,
    Object? selectedStatus = _keep,
    bool? isLoading,
    List<PayslipEntry>? entries,
    Object? errorMessage = _keep,
    Object? sheet = _keep,
    Object? snackbarMessage = _keep,
  }) {
    return PaymentStatusUiState(
      periods: periods ?? this.periods,
      selectedPeriod: identical(selectedPeriod, _keep) ? this.selectedPeriod : selectedPeriod as PayrollPeriod?,
      areas: areas ?? this.areas,
      selectedArea: identical(selectedArea, _keep) ? this.selectedArea : selectedArea as PayrollArea?,
      selectedStatus: identical(selectedStatus, _keep) ? this.selectedStatus : selectedStatus as PaymentStatus?,
      isLoading: isLoading ?? this.isLoading,
      entries: entries ?? this.entries,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
      sheet: identical(sheet, _keep) ? this.sheet : sheet as PaymentSheetForm?,
      snackbarMessage: identical(snackbarMessage, _keep) ? this.snackbarMessage : snackbarMessage as String?,
    );
  }
}
