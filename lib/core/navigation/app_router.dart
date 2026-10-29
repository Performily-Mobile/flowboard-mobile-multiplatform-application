import 'package:flutter/material.dart';
import 'package:flowboard/core/navigation/app_routes.dart';
import 'package:flowboard/core/navigation/more_page.dart';
import 'package:flowboard/core/navigation/pending_feature_page.dart';

/// Builds the page of every route.
///
/// Each bounded context replaces its entries of [_pendingTitles] with its real screens as it
/// is integrated; routes not integrated yet show a temporary screen.
class AppRouter {
  const AppRouter._();

  static const Map<String, String> _pendingTitles = <String, String>{
    AppRoutes.panel: 'Panel',
    AppRoutes.home: 'Inicio',
    AppRoutes.employees: 'Personal',
    AppRoutes.requests: 'Solicitudes',
    AppRoutes.attendance: 'Asistencia',
    AppRoutes.payslips: 'Boletas',
    AppRoutes.myProfile: 'Mi perfil',
    AppRoutes.organization: 'Organización',
    AppRoutes.payroll: 'Boletas y pagos',
    AppRoutes.wellbeing: 'Bienestar',
    AppRoutes.benefits: 'Beneficios',
    AppRoutes.myBenefits: 'Mis beneficios',
    AppRoutes.myVacationBalance: 'Mi saldo de vacaciones',
    AppRoutes.requestTypes: 'Tipos de solicitud',
    AppRoutes.account: 'Cuenta y seguridad',
  };

  /// Creates the route for [settings].
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final String? name = settings.name;
    final Widget page;

    if (name == AppRoutes.more) {
      page = const MorePage();
    } else if (name == AppRoutes.pendingFeature) {
      page = PendingFeaturePage(title: settings.arguments as String? ?? 'Sección');
    } else if (name != null && _pendingTitles.containsKey(name)) {
      page = PendingFeaturePage(title: _pendingTitles[name]!);
    } else {
      page = const PendingFeaturePage(title: 'Flowboard');
    }

    return MaterialPageRoute<void>(settings: settings, builder: (BuildContext context) => page);
  }
}
