import 'package:flowboard/features/workspace/domain/entity/position.dart';
import 'package:flowboard/features/workspace/domain/repository/position_repository.dart';

/// Lists the positions sorted by title.
class GetPositionsUseCase {
  /// Creates the use case.
  const GetPositionsUseCase({required this.repository});

  final PositionRepository repository;

  /// Positions of [areaId] (all when null) sorted by title; only the active ones when
  /// [onlyActive] is true.
  Future<List<Position>> execute({int? areaId, bool onlyActive = false}) async {
    final List<Position> positions = await repository.getPositions(areaId);
    return positions.where((Position position) => !onlyActive || position.active).toList()
      ..sort((Position a, Position b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
  }
}
