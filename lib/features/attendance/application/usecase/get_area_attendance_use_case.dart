import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/repository/attendance_repository.dart';

class GetAreaAttendanceUseCase {
  const GetAreaAttendanceUseCase(this.repository);

  final AttendanceRepository repository;

  Future<List<AttendanceRecord>> call(int id, DateTime date) =>
      repository.areaRecords(id, date);
}