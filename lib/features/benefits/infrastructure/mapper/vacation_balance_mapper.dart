import 'package:flowboard/features/benefits/domain/entity/vacation_balance.dart';
import 'package:flowboard/features/benefits/domain/valueobject/adjustment_operation.dart';
import 'package:flowboard/features/benefits/infrastructure/mapper/benefits_enum_mapper.dart';
import 'package:flowboard/features/benefits/infrastructure/remote/vacation_balance_dto.dart';

/// Translates the vacation balances between the API and the domain.
class VacationBalanceMapper {
  const VacationBalanceMapper._();

  /// Domain balance of [dto], with its movements from the most recent to the oldest.
  static VacationBalance toDomain(VacationBalanceDto dto) {
    final List<VacationMovement> movements = dto.movements
        .map((VacationMovementDto movement) => VacationMovement(
              id: movement.id,
              type: BenefitsEnumMapper.movementType(movement.type),
              days: movement.days,
              reason: _blankToNull(movement.reason),
              authorName: _blankToNull(movement.authorName),
              requestId: movement.requestId,
              occurredAt: BenefitsEnumMapper.dateTime(movement.occurredAt) ?? DateTime(1970),
            ))
        .toList()
      ..sort((VacationMovement a, VacationMovement b) => b.occurredAt.compareTo(a.occurredAt));
    return VacationBalance(
      employeeId: dto.employeeId,
      employeeName: _blankToNull(dto.employeeName),
      areaName: _blankToNull(dto.areaName),
      accruedDays: dto.accruedDays,
      usedDays: dto.usedDays,
      availableDays: dto.availableDays,
      lastAccrualDate: BenefitsEnumMapper.date(dto.lastAccrualDate),
      movements: movements,
    );
  }

  /// Body of a manual adjustment.
  static AdjustVacationBalanceRequestDto toAdjustRequest(
    AdjustmentOperation operation,
    double days,
    String reason,
    int authorId,
  ) {
    return AdjustVacationBalanceRequestDto(
      operation: BenefitsEnumMapper.operation(operation),
      days: days,
      reason: reason,
      authorId: authorId,
    );
  }

  static String? _blankToNull(String? value) => value == null || value.trim().isEmpty ? null : value;
}
