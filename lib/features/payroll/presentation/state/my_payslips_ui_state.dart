import 'package:flowboard/features/payroll/domain/entity/payslip.dart';
import 'package:flowboard/features/payroll/domain/valueobject/payment_status.dart';
import 'package:flowboard/features/payroll/presentation/ui/components/payroll_formatters.dart';

const Object _keep = Object();

/// Message of the snackbar; with [openUrl] it shows the "Abrir" action (MA-65).
class PayslipsSnackbar {
  /// Creates the message.
  const PayslipsSnackbar({required this.message, this.openUrl});

  final String message;
  final String? openUrl;
}

/// State of "Mis boletas" of the employee (MA-64, MA-65).
class MyPayslipsUiState {
  /// Creates the state; the payslips start locked.
  const MyPayslipsUiState({
    this.isLocked = true,
    this.isVerifying = false,
    this.lockMessage,
    required this.selectedYear,
    required this.years,
    this.isLoading = false,
    this.payslips = const <Payslip>[],
    this.errorMessage,
    this.downloadingId,
    this.snackbar,
    this.query = '',
  });

  final bool isLocked;
  final bool isVerifying;

  /// Why the last verification did not unlock the payslips.
  final String? lockMessage;
  final int selectedYear;
  final List<int> years;
  final bool isLoading;
  final List<Payslip> payslips;
  final String? errorMessage;
  final int? downloadingId;
  final PayslipsSnackbar? snackbar;

  /// Text of the search box: month, amount or status of the payslip.
  final String query;

  /// Payslips of the year that match the search.
  List<Payslip> get visiblePayslips => query.trim().isEmpty
      ? payslips
      : payslips
          .where((Payslip payslip) => PayrollFormatters.matches(<String>[
                payslip.period.label,
                PayrollFormatters.money(payslip.netAmount),
                payslip.payment.status.label,
              ], query))
          .toList();

  /// True when a payslip still waits for its deposit, to show the note under the list.
  bool get hasPending => payslips.any((Payslip payslip) => payslip.payment.status == PaymentStatus.pending);

  /// Copy with the given values replaced.
  MyPayslipsUiState copyWith({
    bool? isLocked,
    bool? isVerifying,
    Object? lockMessage = _keep,
    int? selectedYear,
    bool? isLoading,
    List<Payslip>? payslips,
    Object? errorMessage = _keep,
    Object? downloadingId = _keep,
    Object? snackbar = _keep,
    String? query,
  }) {
    return MyPayslipsUiState(
      isLocked: isLocked ?? this.isLocked,
      isVerifying: isVerifying ?? this.isVerifying,
      lockMessage: identical(lockMessage, _keep) ? this.lockMessage : lockMessage as String?,
      selectedYear: selectedYear ?? this.selectedYear,
      years: years,
      isLoading: isLoading ?? this.isLoading,
      payslips: payslips ?? this.payslips,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
      downloadingId: identical(downloadingId, _keep) ? this.downloadingId : downloadingId as int?,
      snackbar: identical(snackbar, _keep) ? this.snackbar : snackbar as PayslipsSnackbar?,
      query: query ?? this.query,
    );
  }
}
