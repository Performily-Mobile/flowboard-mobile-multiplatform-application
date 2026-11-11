import 'package:flowboard/features/attendance/application/usecase/attendance_people_resolver.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_page.dart';
import 'package:flowboard/features/attendance/domain/repository/attendance_repository.dart';
import 'package:flowboard/features/attendance/domain/valueobject/attendance_period.dart';
import 'package:flowboard/features/attendance/domain/valueobject/attendance_status.dart';

/// Gets one page of the attendance records of the whole staff; only for the HR staff.
class GetAttendanceRecordsUseCase {
  /// Creates the use case.
  const GetAttendanceRecordsUseCase({required this.repository, required this.peopleResolver});

  final AttendanceRepository repository;
  final AttendancePeopleResolver peopleResolver;

  /// Page [page] of the records in [period] with [status], or of every status when it is null.
  Future<AttendancePage> execute({required AttendancePeriod period, AttendanceStatus? status, int page = 0}) async {
    final AttendancePage result = await repository.getRecords(
      period: period,
      status: status,
      page: page,
      size: AttendancePage.defaultSize,
    );
    return peopleResolver.resolvePage(result);
  }
}
