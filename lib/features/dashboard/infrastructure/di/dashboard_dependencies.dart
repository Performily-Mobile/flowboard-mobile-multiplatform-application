import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/navigation/feature_route_registry.dart';
import 'package:flowboard/core/network/api_client.dart';
import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/features/dashboard/application/usecase/get_hr_dashboard_use_case.dart';
import 'package:flowboard/features/dashboard/domain/repository/hr_dashboard_repository.dart';
import 'package:flowboard/features/dashboard/infrastructure/remote/dashboard_attendance_service.dart';
import 'package:flowboard/features/dashboard/infrastructure/remote/dashboard_request_service.dart';
import 'package:flowboard/features/dashboard/infrastructure/remote/dashboard_vacation_service.dart';
import 'package:flowboard/features/dashboard/infrastructure/repository/hr_dashboard_repository_impl.dart';
import 'package:flowboard/features/dashboard/presentation/ui/navigation/dashboard_navigation.dart';
import 'package:flowboard/features/dashboard/presentation/viewmodel/hr_dashboard_view_model.dart';
import 'package:flowboard/features/workspace/application/usecase/get_areas_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_current_employee_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_employees_use_case.dart';

/// Registers the dependencies of the Dashboard bounded context.
///
/// It must run after the Workspace setup, because the dashboard reads its use cases.
void setupDashboardDependencies() {
  getIt
    ..registerLazySingleton<DashboardAttendanceService>(() => DashboardAttendanceService(client: getIt<ApiClient>()))
    ..registerLazySingleton<DashboardRequestService>(() => DashboardRequestService(client: getIt<ApiClient>()))
    ..registerLazySingleton<DashboardVacationService>(() => DashboardVacationService(client: getIt<ApiClient>()))
    ..registerLazySingleton<HrDashboardRepository>(() => HrDashboardRepositoryImpl(
          getCurrentEmployee: getIt<GetCurrentEmployeeUseCase>(),
          getAreas: getIt<GetAreasUseCase>(),
          getEmployees: getIt<GetEmployeesUseCase>(),
          currentEmployeeProvider: getIt<CurrentEmployeeProvider>(),
          attendanceService: getIt<DashboardAttendanceService>(),
          requestService: getIt<DashboardRequestService>(),
          vacationService: getIt<DashboardVacationService>(),
        ))
    ..registerLazySingleton<GetHrDashboardUseCase>(
        () => GetHrDashboardUseCase(repository: getIt<HrDashboardRepository>()))
    ..registerFactory<HrDashboardViewModel>(() => HrDashboardViewModel(getHrDashboard: getIt<GetHrDashboardUseCase>()));

  getIt<FeatureRouteRegistry>().register(DashboardNavigation.pageFor);
}
