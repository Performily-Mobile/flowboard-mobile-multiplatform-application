import 'package:flowboard/core/navigation/app_routes.dart';

/// Routes of the Payroll bounded context.
///
/// "Boletas y pagos" (HR, opened from "Más") and "Boletas" (employee tab) reuse the names of the
/// core navigation. The payslip viewer is pushed inside the "Boletas" tab.
class PayrollRoutes {
  const PayrollRoutes._();

  static const String uploadPayslips = AppRoutes.payroll;
  static const String myPayslips = AppRoutes.payslips;
  static const String payslipViewer = '/payslip-viewer';
}

/// Arguments of [PayrollRoutes.payslipViewer].
class PayslipViewerArgs {
  /// Creates the arguments; [title] is shown while the payslip loads.
  const PayslipViewerArgs({required this.payslipId, required this.title});

  final int payslipId;
  final String title;
}
