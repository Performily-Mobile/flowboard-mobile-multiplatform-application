import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/repository/attendance_repository.dart';

class GetAttendanceHoursUseCase {
  const GetAttendanceHoursUseCase(this.repository);

  final AttendanceRepository repository;

  Future> dynamic call(
    int id,
    DateTime from,
    DateTime to,
  ) =>
      repository.employeeHours(id, from, to);
}