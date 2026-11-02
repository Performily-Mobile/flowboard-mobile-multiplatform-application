import 'package:flowboard/core/domain/money.dart';
import 'package:flowboard/features/workspace/domain/entity/position.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/create_position_request_dto.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/position_dto.dart';

/// Translates the positions between the API and the domain.
class PositionMapper {
  const PositionMapper._();

  /// Domain position of [dto].
  static Position toDomain(PositionDto dto) {
    return Position(
      id: dto.id,
      title: dto.title,
      areaId: dto.areaId,
      areaName: dto.areaName ?? '',
      referenceSalary: Money(
        amount: dto.referenceSalaryAmount,
        currency: dto.referenceSalaryCurrency ?? Money.defaultCurrency,
      ),
      active: dto.active,
    );
  }

  /// Body to create a position.
  static CreatePositionRequestDto toCreateRequest(String title, int areaId, Money referenceSalary) {
    return CreatePositionRequestDto(
      title: title,
      areaId: areaId,
      referenceSalaryAmount: referenceSalary.amount,
      referenceSalaryCurrency: referenceSalary.currency,
    );
  }
}
