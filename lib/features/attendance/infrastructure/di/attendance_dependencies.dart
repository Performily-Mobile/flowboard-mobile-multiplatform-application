import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/network/api_client.dart';
import 'package:flowboard/features/attendance/domain/repository/attendance_repository.dart';
import 'package:flowboard/features/attendance/infrastructure/remote/attendance_service.dart';
import 'package:flowboard/features/attendance/infrastructure/repository/attendance_repository_impl.dart';

/// Registers the dependencies of the Attendance bounded context.
void setupAttendanceDependencies() {
  getIt
    ..registerLazySingleton<AttendanceService>(() => AttendanceService(client: getIt<ApiClient>()))
    ..registerLazySingleton<AttendanceRepository>(
        () => AttendanceRepositoryImpl(service: getIt<AttendanceService>()));
}
