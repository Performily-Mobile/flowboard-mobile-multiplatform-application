import 'package:flowboard/features/attendance/application/usecase/attendance_people_resolver.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_employee.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/entity/employee_attendance.dart';
import 'package:flowboard/features/attendance/domain/repository/attendance_repository.dart';
import 'package:flowboard/features/attendance/domain/valueobject/attendance_period.dart';

/// Gets the attendance of one employee in a period; only for the HR staff.
class GetEmployeeAttendanceUseCase {
  /// Creates the use case.
  const GetEmployeeAttendanceUseCase({required this.repository, required this.peopleResolver});

  final AttendanceRepository repository;
  final AttendancePeopleResolver peopleResolver;

  /// Attendance of the employee [employeeId] in [period].
  Future<EmployeeAttendance> execute(int employeeId, AttendancePeriod period) async {
    final Future<AttendanceEmployee?> employee = peopleResolver.employee(employeeId);
    final List<AttendanceRecord> records = await repository.getEmployeeRecords(employeeId, period);
    final AttendanceEmployee? data = await employee;
    return EmployeeAttendance(
      employeeId: employeeId,
      employee: data,
      records: records.map((AttendanceRecord record) => record.withEmployee(data)).toList()
        ..sort(AttendanceRecord.newestFirst),
    );
  }
}
