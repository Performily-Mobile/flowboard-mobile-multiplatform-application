import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/repository/attendance_repository.dart';

class JustifyAttendanceUseCase {
  const JustifyAttendanceUseCase(this.repository);

  final AttendanceRepository repository;

  Future<AttendanceRecord> call(
    int id,
    String reason,
    String? url,
  ) =>
      repository.justify(id, reason, url);
}