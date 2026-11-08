import 'package:flowboard/features/payroll/domain/entity/payslip_detail.dart';

const Object _keep = Object();

/// State of the payslip viewer of the employee (MA-66).
class PayslipViewerUiState {
  /// Creates the state.
  const PayslipViewerUiState({
    this.isLoading = false,
    this.detail,
    this.errorMessage,
    this.isDownloading = false,
    this.openUrl,
    this.snackbarMessage,
  });

  final bool isLoading;
  final PayslipDetail? detail;
  final String? errorMessage;
  final bool isDownloading;

  /// Temporary link the screen opens once it is ready.
  final String? openUrl;
  final String? snackbarMessage;

  /// Copy with the given values replaced.
  PayslipViewerUiState copyWith({
    bool? isLoading,
    Object? detail = _keep,
    Object? errorMessage = _keep,
    bool? isDownloading,
    Object? openUrl = _keep,
    Object? snackbarMessage = _keep,
  }) {
    return PayslipViewerUiState(
      isLoading: isLoading ?? this.isLoading,
      detail: identical(detail, _keep) ? this.detail : detail as PayslipDetail?,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
      isDownloading: isDownloading ?? this.isDownloading,
      openUrl: identical(openUrl, _keep) ? this.openUrl : openUrl as String?,
      snackbarMessage: identical(snackbarMessage, _keep) ? this.snackbarMessage : snackbarMessage as String?,
    );
  }
}
