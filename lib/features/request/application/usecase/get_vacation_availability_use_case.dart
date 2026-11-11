import 'package:flowboard/features/request/domain/entity/vacation_availability.dart';
import 'package:flowboard/features/request/domain/repository/vacation_balance_provider.dart';

/// Gets the vacation days available to an employee.
class GetVacationAvailabilityUseCase {
  /// Creates the use case.
  const GetVacationAvailabilityUseCase({required this.provider});

  final VacationBalanceProvider provider;

  /// Available days of [employeeId], or of the current employee when it is null.
  Future<VacationAvailability> execute({int? employeeId}) {
    return employeeId == null ? provider.getMyAvailability() : provider.getAvailability(employeeId);
  }
}
