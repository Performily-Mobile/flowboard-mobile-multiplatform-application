import 'package:flutter/widgets.dart';
import 'package:flowboard/features/benefits/presentation/ui/navigation/benefits_routes.dart';
import 'package:flowboard/features/benefits/presentation/ui/screens/assign_benefit_screen.dart';
import 'package:flowboard/features/benefits/presentation/ui/screens/benefits_admin_screen.dart';
import 'package:flowboard/features/benefits/presentation/ui/screens/my_benefits_screen.dart';
import 'package:flowboard/features/benefits/presentation/ui/screens/my_vacation_balance_screen.dart';
import 'package:flowboard/features/benefits/presentation/ui/screens/vacation_balance_detail_screen.dart';
import 'package:flowboard/features/benefits/presentation/ui/screens/vacation_balances_screen.dart';

/// Page builder of the Benefits routes, registered in the core route registry.
class BenefitsNavigation {
  const BenefitsNavigation._();

  /// Page of [settings], or null when the route does not belong to Benefits.
  static Widget? pageFor(RouteSettings settings) {
    switch (settings.name) {
      case BenefitsRoutes.benefitsAdmin:
        return const BenefitsAdminScreen();
      case BenefitsRoutes.assignBenefit:
        return const AssignBenefitScreen();
      case BenefitsRoutes.vacationBalances:
        return const VacationBalancesScreen();
      case BenefitsRoutes.vacationBalanceDetail:
        final VacationBalanceDetailArgs args = settings.arguments as VacationBalanceDetailArgs;
        return VacationBalanceDetailScreen(employeeId: args.employeeId, employeeName: args.employeeName);
      case BenefitsRoutes.myBenefits:
        return const MyBenefitsScreen();
      case BenefitsRoutes.myVacationBalance:
        return const MyVacationBalanceScreen();
    }
    return null;
  }
}
