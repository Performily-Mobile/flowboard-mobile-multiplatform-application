import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/payroll/application/usecase/get_my_payslip_download_link_use_case.dart';
import 'package:flowboard/features/payroll/application/usecase/get_my_payslips_use_case.dart';
import 'package:flowboard/features/payroll/application/usecase/unlock_my_payslips_use_case.dart';
import 'package:flowboard/features/payroll/domain/entity/payslip.dart';
import 'package:flowboard/features/payroll/domain/entity/payslip_download_link.dart';
import 'package:flowboard/features/payroll/domain/repository/identity_verifier.dart';
import 'package:flowboard/features/payroll/presentation/state/my_payslips_ui_state.dart';
import 'package:flowboard/features/payroll/presentation/viewmodel/payroll_error_messages.dart';

/// View model of "Mis boletas" of the employee (MA-64, MA-65, US41, US42).
///
/// The payslips stay hidden until the employee verifies their identity (UF-03); then the published
/// payslips of the selected year are listed and each one can be downloaded.
class MyPayslipsViewModel extends ViewModel<MyPayslipsUiState> {
  /// Creates the view model; it loads the payslips at once when they were already unlocked.
  MyPayslipsViewModel({
    required this.unlockMyPayslips,
    required this.getMyPayslips,
    required this.getDownloadLink,
    DateTime? today,
  }) : super(_initialState(today ?? DateTime.now(), unlockMyPayslips.isUnlocked)) {
    if (!state.isLocked) load();
  }

  final UnlockMyPayslipsUseCase unlockMyPayslips;
  final GetMyPayslipsUseCase getMyPayslips;
  final GetMyPayslipDownloadLinkUseCase getDownloadLink;

  /// Years offered in the chips of MA-65: the current one and the two before it.
  static const int _yearsShown = 3;

  int _request = 0;

  static MyPayslipsUiState _initialState(DateTime today, bool unlocked) {
    return MyPayslipsUiState(
      isLocked: !unlocked,
      selectedYear: today.year,
      years: <int>[for (int i = 0; i < _yearsShown; i++) today.year - i],
    );
  }

  /// "Desbloquear con huella" ([withPassword] false) or "Usar contraseña" ([withPassword] true).
  Future<void> unlock({required bool withPassword}) async {
    if (state.isVerifying) return;
    update((MyPayslipsUiState s) => s.copyWith(isVerifying: true, lockMessage: null));
    final IdentityVerification result = await unlockMyPayslips.execute(withPassword: withPassword);
    switch (result) {
      case IdentityVerification.verified:
        update((MyPayslipsUiState s) => s.copyWith(isVerifying: false, isLocked: false));
        load();
      case IdentityVerification.failed:
        update((MyPayslipsUiState s) => s.copyWith(
              isVerifying: false,
              lockMessage: 'No pudimos verificar tu identidad. Reintenta o usa tu contraseña.',
            ));
      case IdentityVerification.unavailable:
        update((MyPayslipsUiState s) => s.copyWith(
              isVerifying: false,
              lockMessage: 'Tu dispositivo no tiene la huella configurada. Usa tu contraseña.',
            ));
    }
  }

  /// Loads the payslips of the selected year; an answer of an older request is ignored.
  Future<void> load() async {
    final int request = ++_request;
    update((MyPayslipsUiState s) => s.copyWith(isLoading: true, errorMessage: null));
    try {
      final List<Payslip> payslips = await getMyPayslips.execute(state.selectedYear);
      if (request != _request) return;
      update((MyPayslipsUiState s) => s.copyWith(isLoading: false, payslips: payslips));
    } catch (error) {
      if (request != _request) return;
      update((MyPayslipsUiState s) => s.copyWith(
            isLoading: false,
            errorMessage: payrollMessage(error, PayrollAction.load, 'No se pudieron cargar tus boletas.'),
          ));
    }
  }

  /// Selects the [year] chip and loads its payslips.
  void onYearSelected(int year) {
    if (year == state.selectedYear) return;
    update((MyPayslipsUiState s) => s.copyWith(selectedYear: year, payslips: const <Payslip>[]));
    load();
  }

  /// Asks the temporary link of [payslip] and reports it: "Boleta de agosto 2026 descargada · Abrir".
  Future<void> download(Payslip payslip) async {
    if (state.downloadingId != null) return;
    update((MyPayslipsUiState s) => s.copyWith(downloadingId: payslip.id));
    try {
      final PayslipDownloadLink link = await getDownloadLink.execute(payslip.id);
      update((MyPayslipsUiState s) => s.copyWith(
            downloadingId: null,
            snackbar: PayslipsSnackbar(
              message: 'Boleta de ${payslip.period.inlineLabel} descargada',
              openUrl: link.downloadUrl,
            ),
          ));
    } catch (error) {
      update((MyPayslipsUiState s) => s.copyWith(
            downloadingId: null,
            snackbar: PayslipsSnackbar(
              message: payrollMessage(error, PayrollAction.download, 'No se pudo descargar la boleta.'),
            ),
          ));
    }
  }

  /// Filters the list with the text of the search box.
  void onQueryChange(String query) => update((MyPayslipsUiState s) => s.copyWith(query: query));

  /// Clears the snackbar once it was shown.
  void onSnackbarShown() => update((MyPayslipsUiState s) => s.copyWith(snackbar: null));
}
