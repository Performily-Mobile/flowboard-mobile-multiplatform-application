import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/navigation/feature_route_registry.dart';
import 'package:flowboard/core/network/api_client.dart';
import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/features/attendance/application/usecase/attendance_use_cases.dart';
import 'package:flowboard/features/attendance/domain/repository/attendance_repository.dart';
import 'package:flowboard/features/attendance/infrastructure/remote/attendance_service.dart';
import 'package:flowboard/features/attendance/infrastructure/repository/attendance_repository_impl.dart';
import 'package:flowboard/features/attendance/presentation/ui/navigation/attendance_navigation.dart';
import 'package:flowboard/features/attendance/presentation/viewmodel/attendance_area_view_model.dart';
import 'package:flowboard/features/attendance/presentation/viewmodel/attendance_home_view_model.dart';
import 'package:flowboard/features/attendance/presentation/viewmodel/attendance_hours_view_model.dart';
import 'package:flowboard/features/attendance/presentation/viewmodel/attendance_view_model.dart';
import 'package:flowboard/features/attendance/presentation/viewmodel/employee_attendance_view_model.dart';
import 'package:flowboard/features/attendance/presentation/viewmodel/justify_attendance_view_model.dart';
import 'package:flowboard/features/attendance/presentation/viewmodel/my_attendance_view_model.dart';

void setupAttendanceDependencies() {
  getIt
    ..registerLazySingleton<AttendanceService>(
      () => AttendanceService(client: getIt<ApiClient>()),
    )
    ..registerLazySingleton<AttendanceRepository>(
      () => AttendanceRepositoryImpl(service: getIt<AttendanceService>()),
    )
    ..registerLazySingleton<GetMyAttendanceUseCase>(
      () => GetMyAttendanceUseCase(getIt<AttendanceRepository>()),
    )
    ..registerLazySingleton<GetEmployeeAttendanceUseCase>(
      () => GetEmployeeAttendanceUseCase(getIt<AttendanceRepository>()),
    )
    ..registerLazySingleton<GetAreaAttendanceUseCase>(
      () => GetAreaAttendanceUseCase(getIt<AttendanceRepository>()),
    )
    ..registerLazySingleton<GetAttendanceHoursUseCase>(
      () => GetAttendanceHoursUseCase(getIt<AttendanceRepository>()),
    )
    ..registerLazySingleton<RegisterPunchUseCase>(
      () => RegisterPunchUseCase(getIt<AttendanceRepository>()),
    )
    ..registerLazySingleton<JustifyAttendanceUseCase>(
      () => JustifyAttendanceUseCase(getIt<AttendanceRepository>()),
    )
    ..registerFactory<AttendanceViewModel>(
      () => AttendanceViewModel(
        repository: getIt<AttendanceRepository>(),
        employeeProvider: getIt<CurrentEmployeeProvider>(),
      ),
    );

  getIt.registerFactory<AttendanceHomeViewModel>(
    () => AttendanceHomeViewModel(getIt<AttendanceRepository>()),
  );

  getIt.registerFactory<MyAttendanceViewModel>(
    () => MyAttendanceViewModel(getIt<AttendanceRepository>()),
  );

  getIt.registerFactory<EmployeeAttendanceViewModel>(
    () => EmployeeAttendanceViewModel(getIt<AttendanceRepository>()),
  );

  getIt.registerFactory<AttendanceAreaViewModel>(
    () => AttendanceAreaViewModel(getIt<AttendanceRepository>()),
  );

  getIt.registerFactory<AttendanceHoursViewModel>(
    () => AttendanceHoursViewModel(getIt<AttendanceRepository>()),
  );

  getIt.registerFactory<JustifyAttendanceViewModel>(
    () => JustifyAttendanceViewModel(getIt<AttendanceRepository>()),
  );

  getIt<FeatureRouteRegistry>().register(AttendanceNavigation.pageFor);
}