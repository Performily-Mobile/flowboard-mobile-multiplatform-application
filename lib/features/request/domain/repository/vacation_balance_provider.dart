import 'package:flowboard/features/request/domain/entity/vacation_availability.dart';

/// Port to read the vacation balance from Benefits.
abstract class VacationBalanceProvider {
  /// Available days of the current employee.
  Future<VacationAvailability> getMyAvailability();

  /// Available days of [employeeId].
  Future<VacationAvailability> getAvailability(int employeeId);
}
