import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/repository/attendance_repository.dart';

class GetEmployeeAttendanceUseCase {
  const GetEmployeeAttendanceUseCase(this.repository);

  final AttendanceRepository repository;

  Future<List<AttendanceRecord>> call(
    int id,
    DateTime from,
    DateTime to,
  ) =>
      repository.employeeRecords(id, from, to);
}