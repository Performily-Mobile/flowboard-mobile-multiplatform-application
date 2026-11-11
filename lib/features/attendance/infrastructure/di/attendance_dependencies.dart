import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/network/api_client.dart';
import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/features/attendance/application/usecase/attendance_people_resolver.dart';
import 'package:flowboard/features/attendance/application/usecase/get_area_attendance_report_use_case.dart';
import 'package:flowboard/features/attendance/application/usecase/get_area_hours_report_use_case.dart';
import 'package:flowboard/features/attendance/application/usecase/get_attendance_areas_use_case.dart';
import 'package:flowboard/features/attendance/application/usecase/get_attendance_records_use_case.dart';
import 'package:flowboard/features/attendance/application/usecase/get_employee_attendance_use_case.dart';
import 'package:flowboard/features/attendance/application/usecase/get_my_attendance_use_case.dart';
import 'package:flowboard/features/attendance/application/usecase/justify_attendance_use_case.dart';
import 'package:flowboard/features/attendance/application/usecase/register_punch_use_case.dart';
import 'package:flowboard/features/attendance/domain/repository/attendance_directory.dart';
import 'package:flowboard/features/attendance/domain/repository/attendance_repository.dart';
import 'package:flowboard/features/attendance/infrastructure/acl/workspace_attendance_directory_adapter.dart';
import 'package:flowboard/features/attendance/infrastructure/remote/attendance_service.dart';
import 'package:flowboard/features/attendance/infrastructure/repository/attendance_repository_impl.dart';
import 'package:flowboard/features/attendance/presentation/viewmodel/attendance_area_view_model.dart';
import 'package:flowboard/features/attendance/presentation/viewmodel/attendance_home_view_model.dart';
import 'package:flowboard/features/attendance/presentation/viewmodel/attendance_hours_view_model.dart';
import 'package:flowboard/features/attendance/presentation/viewmodel/attendance_records_view_model.dart';
import 'package:flowboard/features/attendance/presentation/viewmodel/employee_attendance_view_model.dart';
import 'package:flowboard/features/attendance/presentation/viewmodel/justify_attendance_view_model.dart';
import 'package:flowboard/features/attendance/presentation/viewmodel/my_attendance_view_model.dart';
import 'package:flowboard/features/workspace/application/usecase/get_areas_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_employees_use_case.dart';

/// Registers the dependencies of the Attendance bounded context.
///
/// Services, repositories and use cases are singletons; view models are created for each screen.
/// The areas and the names of the employees come from the Workspace use cases, which are resolved
/// when they are first used.
void setupAttendanceDependencies() {
  getIt
    ..registerLazySingleton<AttendanceService>(() => AttendanceService(client: getIt<ApiClient>()))
    ..registerLazySingleton<AttendanceRepository>(
        () => AttendanceRepositoryImpl(service: getIt<AttendanceService>()))
    ..registerLazySingleton<AttendanceDirectory>(() => WorkspaceAttendanceDirectoryAdapter(
          getAreasUseCase: getIt<GetAreasUseCase>(),
          getEmployeesUseCase: getIt<GetEmployeesUseCase>(),
        ))
    ..registerLazySingleton<AttendancePeopleResolver>(
        () => AttendancePeopleResolver(directory: getIt<AttendanceDirectory>()))
    ..registerLazySingleton<GetMyAttendanceUseCase>(
        () => GetMyAttendanceUseCase(repository: getIt<AttendanceRepository>()))
    ..registerLazySingleton<RegisterPunchUseCase>(() => RegisterPunchUseCase(
          repository: getIt<AttendanceRepository>(),
          currentEmployeeProvider: getIt<CurrentEmployeeProvider>(),
        ))
    ..registerLazySingleton<JustifyAttendanceUseCase>(
        () => JustifyAttendanceUseCase(repository: getIt<AttendanceRepository>()))
    ..registerLazySingleton<GetAttendanceRecordsUseCase>(() => GetAttendanceRecordsUseCase(
          repository: getIt<AttendanceRepository>(),
          peopleResolver: getIt<AttendancePeopleResolver>(),
        ))
    ..registerLazySingleton<GetAttendanceAreasUseCase>(
        () => GetAttendanceAreasUseCase(directory: getIt<AttendanceDirectory>()))
    ..registerLazySingleton<GetAreaAttendanceReportUseCase>(() => GetAreaAttendanceReportUseCase(
          repository: getIt<AttendanceRepository>(),
          peopleResolver: getIt<AttendancePeopleResolver>(),
        ))
    ..registerLazySingleton<GetEmployeeAttendanceUseCase>(() => GetEmployeeAttendanceUseCase(
          repository: getIt<AttendanceRepository>(),
          peopleResolver: getIt<AttendancePeopleResolver>(),
        ))
    ..registerLazySingleton<GetAreaHoursReportUseCase>(() => GetAreaHoursReportUseCase(
          repository: getIt<AttendanceRepository>(),
          peopleResolver: getIt<AttendancePeopleResolver>(),
        ))
    ..registerFactory<AttendanceHomeViewModel>(
        () => AttendanceHomeViewModel(currentEmployeeProvider: getIt<CurrentEmployeeProvider>()))
    ..registerFactory<MyAttendanceViewModel>(() => MyAttendanceViewModel(
          getMyAttendance: getIt<GetMyAttendanceUseCase>(),
          registerPunch: getIt<RegisterPunchUseCase>(),
        ))
    ..registerFactory<JustifyAttendanceViewModel>(
        () => JustifyAttendanceViewModel(justifyAttendance: getIt<JustifyAttendanceUseCase>()))
    ..registerFactory<AttendanceRecordsViewModel>(
        () => AttendanceRecordsViewModel(getAttendanceRecords: getIt<GetAttendanceRecordsUseCase>()))
    ..registerFactory<AttendanceAreaViewModel>(() => AttendanceAreaViewModel(
          getAttendanceAreas: getIt<GetAttendanceAreasUseCase>(),
          getAreaAttendanceReport: getIt<GetAreaAttendanceReportUseCase>(),
        ))
    ..registerFactory<EmployeeAttendanceViewModel>(
        () => EmployeeAttendanceViewModel(getEmployeeAttendance: getIt<GetEmployeeAttendanceUseCase>()))
    ..registerFactory<AttendanceHoursViewModel>(() => AttendanceHoursViewModel(
          getAttendanceAreas: getIt<GetAttendanceAreasUseCase>(),
          getAreaHoursReport: getIt<GetAreaHoursReportUseCase>(),
        ));
}
