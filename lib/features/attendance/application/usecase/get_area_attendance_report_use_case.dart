import 'package:flowboard/features/attendance/application/usecase/attendance_people_resolver.dart';
import 'package:flowboard/features/attendance/domain/entity/area_attendance_report.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_area_summary.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_employee.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/repository/attendance_repository.dart';
import 'package:flowboard/features/attendance/domain/valueobject/attendance_period.dart';

/// Gets the attendance report of an area: totals, employees and records; only for the HR staff.
class GetAreaAttendanceReportUseCase {
  /// Creates the use case.
  const GetAreaAttendanceReportUseCase({required this.repository, required this.peopleResolver});

  final AttendanceRepository repository;
  final AttendancePeopleResolver peopleResolver;

  /// Report of the area [areaId] in [period].
  Future<AreaAttendanceReport> execute(int areaId, AttendancePeriod period) async {
    final List<Object> results = await Future.wait<Object>(<Future<Object>>[
      repository.getAreaSummary(areaId, period),
      peopleResolver.employeesOfArea(areaId),
      repository.getAreaRecords(areaId, period),
    ]);
    return AreaAttendanceReport(
      summary: results[0] as AttendanceAreaSummary,
      employees: results[1] as List<AttendanceEmployee>,
      records: await peopleResolver.resolveAll(results[2] as List<AttendanceRecord>),
    );
  }
}
