import 'package:flutter/widgets.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/navigation/app_routes.dart';
import 'package:flowboard/core/session/user_role.dart';

/// Tabs of the bottom bar. [route] is the first screen of the tab.
enum TopLevelDestination {
  panel('Panel', FlowboardIcons.gridView, AppRoutes.panel),
  personal('Personal', FlowboardIcons.group, AppRoutes.employees),
  requests('Solicitudes', FlowboardIcons.article, AppRoutes.requests),
  attendance('Asistencia', FlowboardIcons.schedule, AppRoutes.attendance),
  more('Más', FlowboardIcons.menu, AppRoutes.more),
  home('Inicio', FlowboardIcons.home, AppRoutes.home),
  payslips('Boletas', FlowboardIcons.creditCard, AppRoutes.payslips),
  profile('Perfil', FlowboardIcons.person, AppRoutes.myProfile);

  const TopLevelDestination(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;

  /// Tabs of each role. HR has its management bar; its employee view (My profile, My record)
  /// is inside "Más" › "Mi perfil y autogestión".
  static List<TopLevelDestination> forRole(UserRole role) {
    switch (role) {
      case UserRole.humanResources:
        return const <TopLevelDestination>[panel, personal, requests, attendance, more];
      case UserRole.employee:
        return const <TopLevelDestination>[home, requests, attendance, payslips, profile];
    }
  }
}
