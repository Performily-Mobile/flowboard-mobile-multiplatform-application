import 'package:flowboard/features/benefits/domain/valueobject/vacation_movement_type.dart';

/// Vacation balance of an employee (US41) with its movements, from the most recent to the oldest.
class VacationBalance {
  /// Creates the balance.
  const VacationBalance({
    required this.employeeId,
    required this.employeeName,
    required this.areaName,
    required this.accruedDays,
    required this.usedDays,
    required this.availableDays,
    required this.lastAccrualDate,
    required this.movements,
  });

  final int employeeId;
  final String? employeeName;
  final String? areaName;
  final double accruedDays;
  final double usedDays;
  final double availableDays;
  final DateTime? lastAccrualDate;
  final List<VacationMovement> movements;

  /// Share of the accrued days already used, from 0 to 1, for the bar of MA-57.
  double get usedRatio => accruedDays <= 0 ? 0 : (usedDays / accruedDays).clamp(0, 1).toDouble();

  /// Copy with the given values replaced.
  VacationBalance copyWith({String? employeeName, String? areaName, List<VacationMovement>? movements}) {
    return VacationBalance(
      employeeId: employeeId,
      employeeName: employeeName ?? this.employeeName,
      areaName: areaName ?? this.areaName,
      accruedDays: accruedDays,
      usedDays: usedDays,
      availableDays: availableDays,
      lastAccrualDate: lastAccrualDate,
      movements: movements ?? this.movements,
    );
  }
}

/// A change of the balance.
///
/// [days] is the signed effect on the available days: -3 (usage), +2.5 (accrual).
class VacationMovement {
  /// Creates the movement.
  const VacationMovement({
    required this.id,
    required this.type,
    required this.days,
    required this.reason,
    required this.authorName,
    required this.requestId,
    required this.occurredAt,
  });

  final int id;
  final VacationMovementType type;
  final double days;
  final String? reason;
  final String? authorName;
  final int? requestId;
  final DateTime occurredAt;

  /// Copy with the author name replaced.
  VacationMovement withAuthor(String? authorName) => VacationMovement(
        id: id,
        type: type,
        days: days,
        reason: reason,
        authorName: authorName,
        requestId: requestId,
        occurredAt: occurredAt,
      );
}

/// Balance ready to be shown.
///
/// Without connection the last saved copy is used (MA-57) and [syncedAt] tells when it was fetched.
class SyncedVacationBalance {
  /// Creates the synced balance.
  const SyncedVacationBalance({required this.balance, required this.syncedAt, required this.fromCache});

  final VacationBalance balance;
  final DateTime syncedAt;
  final bool fromCache;
}
