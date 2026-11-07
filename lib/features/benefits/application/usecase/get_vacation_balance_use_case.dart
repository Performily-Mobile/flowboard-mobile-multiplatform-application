import 'package:flowboard/features/benefits/domain/entity/vacation_balance.dart';
import 'package:flowboard/features/benefits/domain/repository/vacation_balance_repository.dart';

/// Balance of one employee with its movements (MA-63).
class GetVacationBalanceUseCase {
  /// Creates the use case.
  const GetVacationBalanceUseCase({required this.repository});

  final VacationBalanceRepository repository;

  /// Balance of the employee [employeeId].
  Future<VacationBalance> execute(int employeeId) => repository.getBalance(employeeId);
}
