import 'package:flowboard/features/workspace/domain/entity/area.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/area_dto.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/create_area_request_dto.dart';

/// Translates the areas between the API and the domain.
class AreaMapper {
  const AreaMapper._();

  /// Domain area of [dto].
  static Area toDomain(AreaDto dto) {
    return Area(
      id: dto.id,
      name: dto.name,
      description: dto.description,
      active: dto.active,
      activeEmployees: dto.activeEmployees,
    );
  }

  /// Body to create an area.
  static CreateAreaRequestDto toCreateRequest(String name, String? description) =>
      CreateAreaRequestDto(name: name, description: description);
}
