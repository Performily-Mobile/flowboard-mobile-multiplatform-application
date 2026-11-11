import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/network/api_client.dart';
import 'package:flowboard/features/attendance/domain/repository/attendance_directory.dart';
import 'package:flowboard/features/attendance/domain/repository/attendance_repository.dart';
import 'package:flowboard/features/attendance/infrastructure/acl/workspace_attendance_directory_adapter.dart';
import 'package:flowboard/features/attendance/infrastructure/remote/attendance_service.dart';
import 'package:flowboard/features/attendance/infrastructure/repository/attendance_repository_impl.dart';
import 'package:flowboard/features/workspace/application/usecase/get_areas_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_employees_use_case.dart';

/// Registers the dependencies of the Attendance bounded context.
///
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
        ));
}
