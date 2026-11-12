import 'dart:async';

import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/payroll/application/usecase/get_payroll_areas_use_case.dart';
import 'package:flowboard/features/payroll/application/usecase/get_payroll_periods_use_case.dart';
import 'package:flowboard/features/payroll/application/usecase/get_payslips_by_period_use_case.dart';
import 'package:flowboard/features/payroll/application/usecase/mark_payslip_as_observed_use_case.dart';
import 'package:flowboard/features/payroll/application/usecase/mark_payslip_as_paid_use_case.dart';
import 'package:flowboard/features/payroll/application/usecase/payslip_entry.dart';
import 'package:flowboard/features/payroll/application/usecase/payslip_upload_result.dart';
import 'package:flowboard/features/payroll/application/usecase/publish_period_payslips_use_case.dart';
import 'package:flowboard/features/payroll/application/usecase/replace_payslip_file_use_case.dart';
import 'package:flowboard/features/payroll/application/usecase/upload_payslip_use_case.dart';
import 'package:flowboard/features/payroll/application/usecase/validate_payslip_file_use_case.dart';
import 'package:flowboard/features/payroll/domain/entity/payroll_area.dart';
import 'package:flowboard/features/payroll/domain/entity/payroll_period.dart';
import 'package:flowboard/features/payroll/domain/entity/payslip.dart';
import 'package:flowboard/features/payroll/domain/valueobject/payment_details.dart';
import 'package:flowboard/features/payroll/domain/valueobject/payment_status.dart';
import 'package:flowboard/features/payroll/domain/valueobject/payroll_system_file.dart';
import 'package:flowboard/features/payroll/presentation/state/payment_sheet_form.dart';
import 'package:flowboard/features/payroll/presentation/state/upload_payslips_ui_state.dart';
import 'package:flowboard/features/payroll/presentation/viewmodel/payroll_error_messages.dart';

/// View model of "Boletas y pagos" of HR (MA-67, MA-68, MA-69, US43-US46).
///
/// It lists the payslips of the period with their payment status, filters them by area and status,
/// registers each deposit as paid or observed, uploads the PDFs of the payroll system (asking before
/// replacing a payslip that already exists) and publishes the payslips of the period.
class UploadPayslipsViewModel extends ViewModel<UploadPayslipsUiState> {
  /// Creates the view model and loads the periods.
  UploadPayslipsViewModel({
    required this.getPayrollPeriods,
    required this.getPayslipsByPeriod,
    required this.uploadPayslip,
    required this.replacePayslipFile,
    required this.publishPeriodPayslips,
    required this.validatePayslipFile,
    required this.getPayrollAreas,
    required this.markPayslipAsPaid,
    required this.markPayslipAsObserved,
  }) : super(const UploadPayslipsUiState()) {
    _loadAreas();
    loadPeriods();
  }

  final GetPayrollPeriodsUseCase getPayrollPeriods;
  final GetPayslipsByPeriodUseCase getPayslipsByPeriod;
  final UploadPayslipUseCase uploadPayslip;
  final ReplacePayslipFileUseCase replacePayslipFile;
  final PublishPeriodPayslipsUseCase publishPeriodPayslips;
  final ValidatePayslipFileUseCase validatePayslipFile;
  final GetPayrollAreasUseCase getPayrollAreas;
  final MarkPayslipAsPaidUseCase markPayslipAsPaid;
  final MarkPayslipAsObservedUseCase markPayslipAsObserved;

  int _payslipsRequest = 0;
  Completer<bool>? _replaceDecision;

  /// Loads the periods and keeps the selected one when it still exists.
  Future<void> loadPeriods() async {
    update((UploadPayslipsUiState s) => s.copyWith(isLoadingPeriods: true, errorMessage: null));
    try {
      final List<PayrollPeriod> periods = await getPayrollPeriods.execute();
      final int? currentId = state.selectedPeriod?.id;
      PayrollPeriod? selected = periods.isEmpty ? null : periods.first;
      for (final PayrollPeriod period in periods) {
        if (period.id == currentId) selected = period;
      }
      update((UploadPayslipsUiState s) =>
          s.copyWith(isLoadingPeriods: false, periods: periods, selectedPeriod: selected));
      if (selected != null) {
        await loadPayslips();
      } else {
        update((UploadPayslipsUiState s) => s.copyWith(entries: const <PayslipEntry>[]));
      }
    } catch (error) {
      update((UploadPayslipsUiState s) => s.copyWith(
            isLoadingPeriods: false,
            errorMessage: payrollMessage(error, PayrollAction.load, 'No se pudieron cargar los períodos.'),
          ));
    }
  }

  /// Selects the [period] and loads its payslips.
  void onPeriodSelected(PayrollPeriod period) {
    if (period.id == state.selectedPeriod?.id) return;
    update((UploadPayslipsUiState s) =>
        s.copyWith(selectedPeriod: period, entries: const <PayslipEntry>[], bannerMessage: null));
    loadPayslips();
  }

  /// Loads the payslips of the selected period; an answer of an older request is ignored.
  Future<void> loadPayslips() async {
    final int? periodId = state.selectedPeriod?.id;
    if (periodId == null) return;
    final int request = ++_payslipsRequest;
    update((UploadPayslipsUiState s) => s.copyWith(isLoadingPayslips: true, errorMessage: null));
    try {
      final List<PayslipEntry> entries = await getPayslipsByPeriod.execute(periodId);
      if (request != _payslipsRequest) return;
      update((UploadPayslipsUiState s) => s.copyWith(isLoadingPayslips: false, entries: entries));
    } catch (error) {
      if (request != _payslipsRequest) return;
      update((UploadPayslipsUiState s) => s.copyWith(
            isLoadingPayslips: false,
            errorMessage: payrollMessage(error, PayrollAction.load, 'No se pudieron cargar las boletas.'),
          ));
    }
  }

  /// Validates and uploads the picked [files] one by one.
  ///
  /// Invalid files are listed in the banner; for a duplicated employee HR is asked whether to
  /// replace the payslip (MA-68).
  Future<void> onFilesSelected(List<SelectedPayslipFile> files) async {
    final PayrollPeriod? period = state.selectedPeriod;
    if (period == null || state.isUploading || files.isEmpty) return;
    if (state.isLoadingPeriods || state.isLoadingPayslips || state.errorMessage != null) {
      update((UploadPayslipsUiState s) => s.copyWith(
            bannerMessage: 'Espera a que se carguen las boletas del período antes de subir archivos.',
          ));
      return;
    }

    final List<String> errors = <String>[];
    final List<PayrollSystemFile> valid = <PayrollSystemFile>[];
    for (final SelectedPayslipFile selected in files) {
      try {
        valid.add(validatePayslipFile.execute(
          sourcePath: selected.path,
          fileName: selected.name,
          contentType: selected.contentType,
          sizeInBytes: selected.sizeInBytes,
        ));
      } catch (error) {
        errors.add(payrollMessage(error, PayrollAction.upload, '${selected.name} no es válido.'));
      }
    }
    update((UploadPayslipsUiState s) => s.copyWith(
          bannerMessage: _bannerOf(errors),
          upload: valid.isEmpty ? null : UploadProgress(current: 0, total: valid.length),
        ));
    if (valid.isEmpty) return;

    final List<Payslip> known = state.entries.map((PayslipEntry entry) => entry.payslip).toList();
    int uploaded = 0;
    int replaced = 0;
    for (int index = 0; index < valid.length; index++) {
      if (isDisposed) return;
      final PayrollSystemFile file = valid[index];
      update((UploadPayslipsUiState s) => s.copyWith(upload: UploadProgress(current: index + 1, total: valid.length)));
      try {
        final PayslipUploadResult result = await uploadPayslip.execute(period.id, file, known);
        switch (result) {
          case PayslipUploaded(:final Payslip payslip):
            known.add(payslip);
            uploaded++;
          case PayslipDuplicate(:final Payslip existing):
            if (!existing.canBeReplaced) {
              errors.add('${file.fileName}: el colaborador ya tiene su boleta pagada y no se puede reemplazar.');
            } else if (await _askReplace(existing, period, file)) {
              try {
                final Payslip updated = await replacePayslipFile.execute(existing, file);
                final int position = known.indexWhere((Payslip payslip) => payslip.id == updated.id);
                if (position >= 0) known[position] = updated;
                replaced++;
              } catch (error) {
                errors.add('${file.fileName}: ${payrollMessage(error, PayrollAction.replace, 'No se pudo reemplazar.')}');
              }
            }
        }
      } catch (error) {
        errors.add('${file.fileName}: ${payrollMessage(error, PayrollAction.upload, 'No se pudo cargar.')}');
      }
    }

    update((UploadPayslipsUiState s) => s.copyWith(
          upload: null,
          bannerMessage: _bannerOf(errors),
          snackbarMessage: _summary(uploaded, replaced),
        ));
    await loadPayslips();
  }

  /// HR chose to replace the payslip of the open dialog.
  void onReplaceConfirmed() => _resolveDuplicate(true);

  /// HR kept the existing payslip or closed the dialog.
  void onReplaceCancelled() => _resolveDuplicate(false);

  /// Publishes the payslips of the period still under review.
  Future<void> onPublishClick() async {
    final PayrollPeriod? period = state.selectedPeriod;
    if (period == null || !state.canPublish) return;
    update((UploadPayslipsUiState s) => s.copyWith(isPublishing: true, bannerMessage: null));
    try {
      final int count = await publishPeriodPayslips.execute(period.id);
      update((UploadPayslipsUiState s) => s.copyWith(
            isPublishing: false,
            snackbarMessage: count == 1 ? 'Se publicó 1 boleta.' : 'Se publicaron $count boletas.',
          ));
      await loadPayslips();
    } catch (error) {
      update((UploadPayslipsUiState s) => s.copyWith(
            isPublishing: false,
            snackbarMessage: payrollMessage(error, PayrollAction.publish, 'No se pudieron publicar las boletas.'),
          ));
    }
  }

  /// Filters by [area], or shows every area when it is null.
  void onAreaSelected(PayrollArea? area) => update((UploadPayslipsUiState s) => s.copyWith(selectedArea: area));

  /// Filters by payment [status], or shows every payslip when it is null.
  void onStatusSelected(PaymentStatus? status) =>
      update((UploadPayslipsUiState s) => s.copyWith(selectedStatus: status));

  /// Opens the payment sheet of [entry]; an unpublished payslip cannot register its payment yet.
  void onEntryTap(PayslipEntry entry) {
    if (!entry.payslip.canUpdatePayment) {
      update((UploadPayslipsUiState s) =>
          s.copyWith(snackbarMessage: 'Publica la boleta para registrar su estado de pago.'));
      return;
    }
    final PaymentDetails payment = entry.payslip.payment;
    final DateTime now = DateTime.now();
    update((UploadPayslipsUiState s) => s.copyWith(
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
      update((UploadPayslipsUiState s) => s.copyWith(sheet: s.sheet?.copyWith(choice: choice, error: null)));

  /// Changes the deposit date.
  void onSheetPaidOnChange(DateTime paidOn) =>
      update((UploadPayslipsUiState s) => s.copyWith(sheet: s.sheet?.copyWith(paidOn: paidOn, error: null)));

  /// Changes the reason of the observation, up to 500 characters.
  void onSheetReasonChange(String reason) {
    final String value =
        reason.length > PaymentDetails.reasonMaxLength ? reason.substring(0, PaymentDetails.reasonMaxLength) : reason;
    update((UploadPayslipsUiState s) => s.copyWith(sheet: s.sheet?.copyWith(reason: value, error: null)));
  }

  /// Closes the sheet unless it is saving.
  void dismissSheet() {
    if (state.sheet?.isSaving ?? false) return;
    update((UploadPayslipsUiState s) => s.copyWith(sheet: null));
  }

  /// Saves the chosen status and reloads the payslips of the period.
  Future<void> saveSheet() async {
    final PaymentSheetForm? form = state.sheet;
    if (form == null || !form.canSave) return;
    update((UploadPayslipsUiState s) => s.copyWith(sheet: form.copyWith(isSaving: true, error: null)));
    final Payslip payslip = form.entry.payslip;
    try {
      if (form.choice == PaymentStatus.paid) {
        await markPayslipAsPaid.execute(payslip, form.paidOn!);
      } else {
        await markPayslipAsObserved.execute(payslip, form.reason);
      }
      update((UploadPayslipsUiState s) => s.copyWith(sheet: null, snackbarMessage: 'Estado de pago actualizado.'));
      loadPayslips();
    } catch (error) {
      update((UploadPayslipsUiState s) => s.copyWith(
            sheet: s.sheet?.copyWith(
              isSaving: false,
              error: payrollMessage(error, PayrollAction.registerPayment, 'No se pudo actualizar el estado de pago.'),
            ),
          ));
    }
  }

  /// Filters the list with the text of the search box.
  void onQueryChange(String query) => update((UploadPayslipsUiState s) => s.copyWith(query: query));

  /// Clears the snackbar message once it was shown.
  void onSnackbarShown() => update((UploadPayslipsUiState s) => s.copyWith(snackbarMessage: null));

  Future<void> _loadAreas() async {
    try {
      final List<PayrollArea> areas = await getPayrollAreas.execute();
      update((UploadPayslipsUiState s) => s.copyWith(areas: areas));
    } catch (_) {
      // Without areas the filter stays empty; the list still works.
    }
  }

  Future<bool> _askReplace(Payslip existing, PayrollPeriod period, PayrollSystemFile file) {
    PayslipEntry entry = PayslipEntry(payslip: existing, employee: null);
    for (final PayslipEntry candidate in state.entries) {
      if (candidate.payslip.employeeId == existing.employeeId) entry = candidate;
    }
    final Completer<bool> decision = Completer<bool>();
    _replaceDecision = decision;
    update((UploadPayslipsUiState s) => s.copyWith(
          duplicate: DuplicatePrompt(
            employeeName: entry.fullName,
            periodLabel: period.period.inlineLabel,
            fileName: file.fileName,
          ),
        ));
    return decision.future;
  }

  void _resolveDuplicate(bool replace) {
    update((UploadPayslipsUiState s) => s.copyWith(duplicate: null));
    final Completer<bool>? decision = _replaceDecision;
    _replaceDecision = null;
    if (decision != null && !decision.isCompleted) decision.complete(replace);
  }

  static String? _bannerOf(List<String> errors) {
    final String text = errors.where((String error) => error.trim().isNotEmpty).join('\n');
    return text.isEmpty ? null : text;
  }

  static String? _summary(int uploaded, int replaced) {
    final List<String> parts = <String>[
      if (uploaded > 0) uploaded == 1 ? '1 boleta cargada' : '$uploaded boletas cargadas',
      if (replaced > 0) replaced == 1 ? '1 boleta reemplazada' : '$replaced boletas reemplazadas',
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  @override
  void dispose() {
    final Completer<bool>? decision = _replaceDecision;
    if (decision != null && !decision.isCompleted) decision.complete(false);
    super.dispose();
  }
}
