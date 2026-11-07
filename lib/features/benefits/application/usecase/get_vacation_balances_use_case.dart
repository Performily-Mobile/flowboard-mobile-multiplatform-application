import 'package:flowboard/features/benefits/domain/entity/vacation_balance.dart';
import 'package:flowboard/features/benefits/domain/repository/vacation_balance_repository.dart';

/// Balances of the active employees for HR, sorted by name.
class GetVacationBalancesUseCase {
  /// Creates the use case.
  const GetVacationBalancesUseCase({required this.repository});

  final VacationBalanceRepository repository;

  /// Balances, optionally of the area [areaId], sorted by employee name.
  Future<List<VacationBalance>> execute({int? areaId}) async {
    final List<VacationBalance> balances = await repository.getBalances(areaId: areaId);
    return balances
      ..sort((VacationBalance a, VacationBalance b) =>
          (a.employeeName ?? '').toLowerCase().compareTo((b.employeeName ?? '').toLowerCase()));
  }
}
