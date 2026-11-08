import 'package:flutter/widgets.dart';
import 'package:flowboard/features/payroll/presentation/ui/navigation/payroll_routes.dart';
import 'package:flowboard/features/payroll/presentation/ui/screens/my_payslips_screen.dart';
import 'package:flowboard/features/payroll/presentation/ui/screens/payslip_viewer_screen.dart';
import 'package:flowboard/features/payroll/presentation/ui/screens/upload_payslips_screen.dart';

/// Page builder of the Payroll routes, registered in the core route registry.
class PayrollNavigation {
  const PayrollNavigation._();

  /// Page of [settings], or null when the route does not belong to Payroll.
  static Widget? pageFor(RouteSettings settings) {
    switch (settings.name) {
      case PayrollRoutes.uploadPayslips:
        return const UploadPayslipsScreen();
      case PayrollRoutes.myPayslips:
        return const MyPayslipsScreen();
      case PayrollRoutes.payslipViewer:
        final PayslipViewerArgs args = settings.arguments as PayslipViewerArgs;
        return PayslipViewerScreen(payslipId: args.payslipId, title: args.title);
    }
    return null;
  }
}
