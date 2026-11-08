import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/payroll/application/usecase/get_payment_status_report_use_case.dart';
import 'package:flowboard/features/payroll/application/usecase/get_payroll_areas_use_case.dart';
import 'package:flowboard/features/payroll/application/usecase/get_payroll_periods_use_case.dart';
import 'package:flowboard/features/payroll/application/usecase/mark_payslip_as_observed_use_case.dart';
import 'package:flowboard/features/payroll/application/usecase/mark_payslip_as_paid_use_case.dart';
import 'package:flowboard/features/payroll/application/usecase/payslip_entry.dart';
import 'package:flowboard/features/payroll/domain/entity/payroll_area.dart';
import 'package:flowboard/features/payroll/domain/entity/payroll_period.dart';
import 'package:flowboard/features/payroll/domain/entity/payslip.dart';
import 'package:flowboard/features/payroll/domain/valueobject/payment_details.dart';
import 'package:flowboard/features/payroll/domain/valueobject/payment_status.dart';
import 'package:flowboard/features/payroll/presentation/state/payment_status_ui_state.dart';
import 'package:flowboard/features/payroll/presentation/viewmodel/payroll_error_messages.dart';

/// View model of the HR payment status screen (MA-69, US45, US46).
///
/// It filters the published payslips by period, area and deposit status and registers each deposit
/// as paid or observed.
class PaymentStatusViewModel extends ViewModel<PaymentStatusUiState> {
  /// Creates the view model; the screen calls [start] with the period it was opened for.
  PaymentStatusViewModel({
    required this.getPayrollPeriods,
    required this.getPayrollAreas,
    required this.getPaymentStatusReport,
    required this.markPayslipAsPaid,
    required this.markPayslipAsObserved,
  }) : super(const PaymentStatusUiState());

  final GetPayrollPeriodsUseCase getPayrollPeriods;
  final GetPayrollAreasUseCase getPayrollAreas;
  final GetPaymentStatusReportUseCase getPaymentStatusReport;
  final MarkPayslipAsPaidUseCase markPayslipAsPaid;
  final MarkPayslipAsObservedUseCase markPayslipAsObserved;

  bool _started = false;
  int _reportRequest = 0;

  /// Loads the periods once, selecting [initialPeriodId] when it exists.
  void start(int? initialPeriodId) {
    if (_started) return;
    _started = true;
    loadPeriods(initialPeriodId: initialPeriodId);
  }

  /// Loads the periods and the report of the selected one.
  Future<void> loadPeriods({int? initialPeriodId}) async {
    final int? wanted = initialPeriodId ?? state.selectedPeriod?.id;
    update((PaymentStatusUiState s) => s.copyWith(isLoading: true, errorMessage: null));
    if (state.areas.isEmpty) _loadAreas();
    try {
      final List<PayrollPeriod> periods = await getPayrollPeriods.execute();
      PayrollPeriod? selected = periods.isEmpty ? null : periods.first;
      for (final PayrollPeriod period in periods) {
        if (period.id == wanted) selected = period;
      }
      update((PaymentStatusUiState s) => s.copyWith(periods: periods, selectedPeriod: selected));
      if (selected != null) {
        await loadReport();
      } else {
        update((PaymentStatusUiState s) => s.copyWith(isLoading: false, entries: const <PayslipEntry>[]));
      }
    } catch (error) {
      update((PaymentStatusUiState s) => s.copyWith(
            isLoading: false,
            errorMessage: payrollMessage(error, PayrollAction.load, 'No se pudo cargar el estado de pagos.'),
          ));
    }
  }

  /// Selects the [period] of the report.
  void onPeriodSelected(PayrollPeriod period) {
    update((PaymentStatusUiState s) => s.copyWith(selectedPeriod: period));
    loadReport();
  }

  /// Filters by [area], or shows every area when it is null.
  void onAreaSelected(PayrollArea? area) {
    update((PaymentStatusUiState s) => s.copyWith(selectedArea: area));
    loadReport();
  }

  /// Filters by [status], or shows every status when it is null.
  void onStatusSelected(PaymentStatus? status) {
    update((PaymentStatusUiState s) => s.copyWith(selectedStatus: status));
    loadReport();
  }

  /// Loads the report of the current filters; an answer of an older request is ignored.
  Future<void> loadReport() async {
    final PayrollPeriod? period = state.selectedPeriod;
    if (period == null) return;
    final int request = ++_reportRequest;
    update((PaymentStatusUiState s) => s.copyWith(isLoading: true, errorMessage: null));
    try {
      final List<PayslipEntry> entries = await getPaymentStatusReport.execute(
        period.id,
        areaId: state.selectedArea?.id,
        status: state.selectedStatus,
      );
      if (request != _reportRequest) return;
      update((PaymentStatusUiState s) => s.copyWith(isLoading: false, entries: entries));
    } catch (error) {
      if (request != _reportRequest) return;
      update((PaymentStatusUiState s) => s.copyWith(
            isLoading: false,
            errorMessage: payrollMessage(error, PayrollAction.load, 'No se pudo cargar el estado de pagos.'),
          ));
    }
  }

  /// Opens the payment sheet of [entry] with its current status.
  void onEntryTap(PayslipEntry entry) {
    final PaymentDetails payment = entry.payslip.payment;
    final DateTime now = DateTime.now();
    update((PaymentStatusUiState s) => s.copyWith(
          sheet: PaymentSheetForm(
            entry: entry,
            subtitle: '${entry.fullName} · ${entry.payslip.period.label}',
            choice: payment.status == PaymentStatus.pending ? null : payment.status,
            paidOn: payment.paidOn ?? DateTime(now.year, now.month, now.day),
            reason: payment.observationReason ?? '',
          ),
        ));
  }

  /// Chooses paid or observed.
  void onSheetChoiceChange(PaymentStatus choice) =>
      update((PaymentStatusUiState s) => s.copyWith(sheet: s.sheet?.copyWith(choice: choice, error: null)));

  /// Changes the deposit date.
  void onSheetPaidOnChange(DateTime paidOn) =>
      update((PaymentStatusUiState s) => s.copyWith(sheet: s.sheet?.copyWith(paidOn: paidOn, error: null)));

  /// Changes the reason of the observation, up to 500 characters.
  void onSheetReasonChange(String reason) {
    final String value =
        reason.length > PaymentDetails.reasonMaxLength ? reason.substring(0, PaymentDetails.reasonMaxLength) : reason;
    update((PaymentStatusUiState s) => s.copyWith(sheet: s.sheet?.copyWith(reason: value, error: null)));
  }

  /// Closes the sheet unless it is saving.
  void dismissSheet() {
    if (state.sheet?.isSaving ?? false) return;
    update((PaymentStatusUiState s) => s.copyWith(sheet: null));
  }

  /// Saves the chosen status and reloads the report.
  Future<void> saveSheet() async {
    final PaymentSheetForm? form = state.sheet;
    if (form == null || !form.canSave) return;
    update((PaymentStatusUiState s) => s.copyWith(sheet: form.copyWith(isSaving: true, error: null)));
    final Payslip payslip = form.entry.payslip;
    try {
      if (form.choice == PaymentStatus.paid) {
        await markPayslipAsPaid.execute(payslip, form.paidOn!);
      } else {
        await markPayslipAsObserved.execute(payslip, form.reason);
      }
      update((PaymentStatusUiState s) => s.copyWith(sheet: null, snackbarMessage: 'Estado de pago actualizado.'));
      loadReport();
    } catch (error) {
      update((PaymentStatusUiState s) => s.copyWith(
            sheet: s.sheet?.copyWith(
              isSaving: false,
              error: payrollMessage(error, PayrollAction.registerPayment, 'No se pudo actualizar el estado de pago.'),
            ),
          ));
    }
  }

  /// Clears the snackbar message once it was shown.
  void onSnackbarShown() => update((PaymentStatusUiState s) => s.copyWith(snackbarMessage: null));

  Future<void> _loadAreas() async {
    try {
      final List<PayrollArea> areas = await getPayrollAreas.execute();
      update((PaymentStatusUiState s) => s.copyWith(areas: areas));
    } catch (error) {
      update((PaymentStatusUiState s) => s.copyWith(
            snackbarMessage:
                'No se pudieron cargar las áreas: ${payrollMessage(error, PayrollAction.load, 'intenta más tarde.')}',
          ));
    }
  }
}
