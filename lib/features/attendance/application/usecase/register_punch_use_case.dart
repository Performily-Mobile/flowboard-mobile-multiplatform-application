import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/repository/attendance_repository.dart';

class RegisterPunchUseCase {
  const RegisterPunchUseCase(this.repository);

  final AttendanceRepository repository;

  Future<int> call(int id, String type) => repository.punch(id, type);
}