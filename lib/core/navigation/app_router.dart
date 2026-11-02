import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/glass_background.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/navigation/app_routes.dart';
import 'package:flowboard/core/navigation/feature_route_registry.dart';
import 'package:flowboard/core/navigation/more_page.dart';
import 'package:flowboard/core/navigation/pending_feature_page.dart';

/// Builds the page of every route.
///
/// The bounded contexts resolve their own routes through the [FeatureRouteRegistry]; routes not
/// integrated yet show a temporary screen. Every page is painted over the glass background.
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
  ///
  /// Routes are untyped so a page can close with a result (for example the id of a new record);
  /// callers push them without a type argument and read the result as an [Object].
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page = getIt<FeatureRouteRegistry>().resolve(settings) ?? _corePage(settings);
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (BuildContext context) => GlassBackground(child: page),
    );
  }

  static Widget _corePage(RouteSettings settings) {
    final String? name = settings.name;
    if (name == AppRoutes.more) return const MorePage();
    if (name == AppRoutes.pendingFeature) {
      return PendingFeaturePage(title: settings.arguments as String? ?? 'Sección');
    }
    if (name != null && _pendingTitles.containsKey(name)) {
      return PendingFeaturePage(title: _pendingTitles[name]!);
    }
    return const PendingFeaturePage(title: 'Flowboard');
  }
}
