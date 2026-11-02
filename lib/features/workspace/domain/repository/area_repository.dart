import 'package:flowboard/features/workspace/domain/entity/area.dart';

/// Repository of the areas of the organization.
abstract class AreaRepository {
  /// All the areas.
  Future<List<Area>> getAreas();

  /// Creates an area with its [name] and optional [description].
  Future<Area> createArea(String name, String? description);

  /// Deactivates the area [id].
  Future<Area> deactivateArea(int id);
}
