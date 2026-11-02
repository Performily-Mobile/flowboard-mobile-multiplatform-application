import 'package:flowboard/core/domain/money.dart';
import 'package:flowboard/features/workspace/domain/entity/position.dart';

/// Repository of the positions of the organization.
abstract class PositionRepository {
  /// Positions of the area [areaId], or all of them when it is null.
  Future<List<Position>> getPositions(int? areaId);

  /// Creates a position of the area [areaId] with its [title] and [referenceSalary].
  Future<Position> createPosition(String title, int areaId, Money referenceSalary);
}
