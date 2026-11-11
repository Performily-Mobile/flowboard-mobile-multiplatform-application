import 'package:flowboard/features/attendance/application/usecase/attendance_people_resolver.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_employee.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_employee_hours.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_hours.dart';
import 'package:flowboard/features/attendance/domain/repository/attendance_repository.dart';
import 'package:flowboard/features/attendance/domain/valueobject/attendance_period.dart';

/// Gets the worked and overtime hours of every employee of an area; only for the HR staff.
///
/// The backend gives the hours one employee at a time, so they are asked in small groups.
class GetAreaHoursReportUseCase {
  /// Creates the use case.
  const GetAreaHoursReportUseCase({required this.repository, required this.peopleResolver});

  final AttendanceRepository repository;
  final AttendancePeopleResolver peopleResolver;

  static const int _groupSize = 5;

  /// Hours of the employees of the area [areaId] in [period], most overtime first.
  Future<List<AttendanceEmployeeHours>> execute(int areaId, AttendancePeriod period) async {
    final List<AttendanceEmployee> employees = await peopleResolver.employeesOfArea(areaId);
    final List<AttendanceEmployeeHours> rows = <AttendanceEmployeeHours>[];
    for (int start = 0; start < employees.length; start += _groupSize) {
      final Iterable<AttendanceEmployee> group = employees.skip(start).take(_groupSize);
      final List<AttendanceHours> hours = await Future.wait(
        group.map((AttendanceEmployee employee) => repository.getEmployeeHours(employee.id, period)),
      );
      int index = 0;
      for (final AttendanceEmployee employee in group) {
        rows.add(AttendanceEmployeeHours(employee: employee, hours: hours[index++]));
      }
    }
    return rows
      ..sort((AttendanceEmployeeHours a, AttendanceEmployeeHours b) {
        final int byOvertime = b.hours.overtimeHours.compareTo(a.hours.overtimeHours);
        return byOvertime != 0 ? byOvertime : a.employee.name.toLowerCase().compareTo(b.employee.name.toLowerCase());
      });
  }
}
