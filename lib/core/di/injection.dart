import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:flowboard/core/navigation/feature_route_registry.dart';
import 'package:flowboard/core/navigation/tab_switcher.dart';
import 'package:flowboard/core/network/api_client.dart';
import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/features/attendance/infrastructure/di/attendance_dependencies.dart';
import 'package:flowboard/features/benefits/infrastructure/di/benefits_dependencies.dart';
import 'package:flowboard/features/dashboard/infrastructure/di/dashboard_dependencies.dart';
import 'package:flowboard/features/iam/infrastructure/di/iam_dependencies.dart';
import 'package:flowboard/features/payroll/infrastructure/di/payroll_dependencies.dart';
import 'package:flowboard/features/request/infrastructure/di/request_dependencies.dart';
import 'package:flowboard/features/wellbeing/infrastructure/di/wellbeing_dependencies.dart';
import 'package:flowboard/features/workspace/infrastructure/di/workspace_dependencies.dart';

/// Service locator of the app.
final GetIt getIt = GetIt.instance;

/// Registers the shared dependencies and then those of each bounded context.
///
/// Each bounded context also registers its routes in the [FeatureRouteRegistry].
void setupDependencies() {
  getIt.registerLazySingleton<http.Client>(() => http.Client());
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(client: getIt<http.Client>()));
  getIt.registerLazySingleton<CurrentEmployeeProvider>(() => CurrentEmployeeProvider());
  getIt.registerLazySingleton<FeatureRouteRegistry>(() => FeatureRouteRegistry());
  getIt.registerLazySingleton<TabSwitcher>(() => TabSwitcher());

  setupIamDependencies();
  setupWorkspaceDependencies();
  setupAttendanceDependencies();
  setupRequestDependencies();
  setupBenefitsDependencies();
  setupPayrollDependencies();
  setupWellbeingDependencies();
  setupDashboardDependencies();
}
