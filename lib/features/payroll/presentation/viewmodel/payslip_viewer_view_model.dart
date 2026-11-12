import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/payroll/application/usecase/get_my_payslip_download_link_use_case.dart';
import 'package:flowboard/features/payroll/application/usecase/get_my_payslip_use_case.dart';
import 'package:flowboard/features/payroll/domain/entity/payslip_detail.dart';
import 'package:flowboard/features/payroll/domain/entity/payslip_download_link.dart';
import 'package:flowboard/features/payroll/presentation/state/payslip_viewer_ui_state.dart';
import 'package:flowboard/features/payroll/presentation/viewmodel/payroll_error_messages.dart';

/// View model of the payslip viewer of the employee (MA-66, US42).
class PayslipViewerViewModel extends ViewModel<PayslipViewerUiState> {
  /// Creates the view model; the screen calls [load] with the payslip it shows.
  PayslipViewerViewModel({required this.getMyPayslip, required this.getDownloadLink})
      : super(const PayslipViewerUiState());

  final GetMyPayslipUseCase getMyPayslip;
  final GetMyPayslipDownloadLinkUseCase getDownloadLink;

  int? _payslipId;

  /// Loads the payslip [payslipId] with the employer data.
  Future<void> load(int payslipId) async {
    _payslipId = payslipId;
    update((PayslipViewerUiState s) => s.copyWith(isLoading: true, errorMessage: null));
    try {
      final PayslipDetail detail = await getMyPayslip.execute(payslipId);
      update((PayslipViewerUiState s) => s.copyWith(isLoading: false, detail: detail));
    } catch (error) {
      update((PayslipViewerUiState s) => s.copyWith(
            isLoading: false,
            errorMessage: payrollMessage(error, PayrollAction.load, 'No se pudo cargar la boleta.'),
          ));
    }
  }

  /// Reloads the payslip after a failure.
  void retry() {
    final int? id = _payslipId;
    if (id != null) load(id);
  }

  /// "Descargar PDF": asks the temporary link, which the screen opens.
  Future<void> download() async {
    final int? id = _payslipId;
    if (id == null || state.isDownloading) return;
    update((PayslipViewerUiState s) => s.copyWith(isDownloading: true));
    try {
      final PayslipDownloadLink link = await getDownloadLink.execute(id);
      update((PayslipViewerUiState s) => s.copyWith(isDownloading: false, openUrl: link.downloadUrl));
    } catch (error) {
      update((PayslipViewerUiState s) => s.copyWith(
            isDownloading: false,
            snackbarMessage: payrollMessage(error, PayrollAction.download, 'No se pudo descargar la boleta.'),
          ));
    }
  }

  /// Clears the link once the screen opened it.
  void onLinkOpened() => update((PayslipViewerUiState s) => s.copyWith(openUrl: null));

  /// Clears the snackbar once it was shown.
  void onSnackbarShown() => update((PayslipViewerUiState s) => s.copyWith(snackbarMessage: null));
}
