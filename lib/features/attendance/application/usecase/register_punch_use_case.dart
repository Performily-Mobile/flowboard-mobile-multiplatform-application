import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/features/attendance/domain/repository/attendance_repository.dart';
import 'package:flowboard/features/attendance/domain/valueobject/punch_type.dart';

/// Registers the check-in or the check-out of the signed-in employee.
class RegisterPunchUseCase {
  /// Creates the use case.
  const RegisterPunchUseCase({required this.repository, required this.currentEmployeeProvider});

  final AttendanceRepository repository;
  final CurrentEmployeeProvider currentEmployeeProvider;

  /// Registers a punch of [type] and returns the identifier of the record.
  Future<int> execute(PunchType type) {
    return repository.registerPunch(employeeId: currentEmployeeProvider.currentEmployeeId().value, type: type);
  }
}
