import 'package:flutter/widgets.dart';
import 'package:flowboard/core/navigation/app_routes.dart';
import 'package:flowboard/features/dashboard/presentation/ui/screens/hr_dashboard_screen.dart';

/// Page builder of the Dashboard routes, registered in the core route registry.
///
/// The dashboard is the "Panel" tab of the HR bottom bar, so it reuses the core route name.
class DashboardNavigation {
  const DashboardNavigation._();

  /// Page of [settings], or null when the route does not belong to the Dashboard.
  static Widget? pageFor(RouteSettings settings) {
    if (settings.name == AppRoutes.panel) return const HrDashboardScreen();
    return null;
  }
}
