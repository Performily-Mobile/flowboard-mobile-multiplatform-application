import 'package:flowboard/core/navigation/app_routes.dart';

/// Routes of the Benefits bounded context.
///
/// The HR screen, the employee screens and the balances list reuse the names of the core
/// navigation ("Más" and the dashboard open them). "Asignar beneficio" is a full-screen form pushed
/// on the root navigator, so the bottom bar is hidden while it is open.
class BenefitsRoutes {
  const BenefitsRoutes._();

  static const String benefitsAdmin = AppRoutes.benefits;
  static const String assignBenefit = '/assign-benefit';
  static const String vacationBalances = AppRoutes.vacationBalances;
  static const String vacationBalanceDetail = '/vacation-balance-detail';
  static const String myBenefits = AppRoutes.myBenefits;
  static const String myVacationBalance = AppRoutes.myVacationBalance;
}

/// Arguments of [BenefitsRoutes.vacationBalanceDetail].
class VacationBalanceDetailArgs {
  /// Creates the arguments; [employeeName] is shown while the balance loads.
  const VacationBalanceDetailArgs({required this.employeeId, required this.employeeName});

  final int employeeId;
  final String employeeName;
}
