import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/features/benefits/domain/entity/vacation_balance.dart';
import 'package:flowboard/features/benefits/domain/repository/vacation_balance_repository.dart';

/// Vacation balance of the employee using the app (MA-57, US41), also without connection.
class GetMyVacationBalanceUseCase {
  /// Creates the use case.
  const GetMyVacationBalanceUseCase({required this.repository, required this.currentEmployeeProvider});

  final VacationBalanceRepository repository;
  final CurrentEmployeeProvider currentEmployeeProvider;

  /// Balance of the signed-in employee with its sync time.
  Future<SyncedVacationBalance> execute() =>
      repository.getMyBalance(currentEmployeeProvider.currentEmployeeId().value);
}
