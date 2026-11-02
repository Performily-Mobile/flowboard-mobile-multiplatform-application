import 'package:flowboard/features/workspace/domain/entity/area.dart';
import 'package:flowboard/features/workspace/domain/repository/area_repository.dart';

/// Deactivates an area that has no active employees.
class DeactivateAreaUseCase {
  /// Creates the use case.
  const DeactivateAreaUseCase({required this.repository});

  final AreaRepository repository;

  /// Deactivates [area]; throws [StateError] when it is already inactive or still has active
  /// employees.
  Future<Area> execute(Area area) {
    if (!area.active) throw StateError('El área ya está desactivada.');
    if (!area.canBeDeactivated) {
      throw StateError('El área tiene colaboradores activos. Reasígnalos antes de desactivarla.');
    }
    return repository.deactivateArea(area.id);
  }
}
