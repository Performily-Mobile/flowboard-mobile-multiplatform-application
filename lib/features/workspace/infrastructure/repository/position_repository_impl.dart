import 'package:flowboard/core/domain/money.dart';
import 'package:flowboard/features/workspace/domain/entity/position.dart';
import 'package:flowboard/features/workspace/domain/repository/position_repository.dart';
import 'package:flowboard/features/workspace/infrastructure/mapper/position_mapper.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/position_dto.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/position_service.dart';

/// Positions read from and written to the Flowboard API.
class PositionRepositoryImpl implements PositionRepository {
  /// Creates the repository.
  const PositionRepositoryImpl({required this.service});

  final PositionService service;

  @override
  Future<List<Position>> getPositions(int? areaId) async {
    final List<PositionDto> dtos = await service.getPositions(areaId);
    return dtos.map(PositionMapper.toDomain).toList();
  }

  @override
  Future<Position> createPosition(String title, int areaId, Money referenceSalary) async {
    final PositionDto dto = await service.createPosition(PositionMapper.toCreateRequest(title, areaId, referenceSalary));
    return PositionMapper.toDomain(dto);
  }
}
