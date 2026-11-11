import 'package:flowboard/features/benefits/application/usecase/get_my_vacation_balance_use_case.dart';
import 'package:flowboard/features/benefits/application/usecase/get_vacation_balance_use_case.dart';
import 'package:flowboard/features/benefits/domain/entity/vacation_balance.dart';
import 'package:flowboard/features/request/domain/entity/vacation_availability.dart';
import 'package:flowboard/features/request/domain/repository/vacation_balance_provider.dart';

/// Reads the vacation balance from the Benefits use cases and translates it into
/// [VacationAvailability].
class BenefitsVacationBalanceAdapter implements VacationBalanceProvider {
  /// Creates the adapter.
  const BenefitsVacationBalanceAdapter({required this.getMyVacationBalance, required this.getVacationBalance});

  final GetMyVacationBalanceUseCase getMyVacationBalance;
  final GetVacationBalanceUseCase getVacationBalance;

  @override
  Future<VacationAvailability> getMyAvailability() async {
    return _toAvailability((await getMyVacationBalance.execute()).balance);
  }

  @override
  Future<VacationAvailability> getAvailability(int employeeId) async {
    return _toAvailability(await getVacationBalance.execute(employeeId));
  }

  VacationAvailability _toAvailability(VacationBalance balance) {
    return VacationAvailability(employeeId: balance.employeeId, availableDays: balance.availableDays);
  }
}
