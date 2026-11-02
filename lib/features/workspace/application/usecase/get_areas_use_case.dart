import 'package:flowboard/features/workspace/domain/entity/area.dart';
import 'package:flowboard/features/workspace/domain/repository/area_repository.dart';

/// Lists the areas sorted by name.
class GetAreasUseCase {
  /// Creates the use case.
  const GetAreasUseCase({required this.repository});

  final AreaRepository repository;

  /// Areas sorted by name; only the active ones when [onlyActive] is true.
  Future<List<Area>> execute({bool onlyActive = false}) async {
    final List<Area> areas = await repository.getAreas();
    return areas.where((Area area) => !onlyActive || area.active).toList()
      ..sort((Area a, Area b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }
}
