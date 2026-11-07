import 'package:flowboard/features/benefits/domain/entity/vacation_balance.dart';
import 'package:flowboard/features/benefits/domain/valueobject/adjustment_operation.dart';

/// Repository of the vacation balances.
abstract class VacationBalanceRepository {
  /// Balance of the employee using the app; without connection it returns the last saved copy (MA-57).
  Future<SyncedVacationBalance> getMyBalance(int employeeId);

  /// Balances of the active employees, optionally of the area [areaId].
  Future<List<VacationBalance>> getBalances({int? areaId});

  /// Balance of the employee [employeeId] with its movements.
  Future<VacationBalance> getBalance(int employeeId);

  /// Adds or deducts [days] from the balance of [employeeId], recording the [reason] and the author.
  Future<VacationBalance> adjust(
    int employeeId,
    AdjustmentOperation operation,
    double days,
    String reason,
    int authorId,
  );
}
