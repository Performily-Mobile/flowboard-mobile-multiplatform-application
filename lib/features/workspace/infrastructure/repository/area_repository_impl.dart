import 'package:flowboard/features/workspace/domain/entity/area.dart';
import 'package:flowboard/features/workspace/domain/repository/area_repository.dart';
import 'package:flowboard/features/workspace/infrastructure/mapper/area_mapper.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/area_dto.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/area_service.dart';

/// Areas read from and written to the Flowboard API.
class AreaRepositoryImpl implements AreaRepository {
  /// Creates the repository.
  const AreaRepositoryImpl({required this.service});

  final AreaService service;

  @override
  Future<List<Area>> getAreas() async {
    final List<AreaDto> dtos = await service.getAreas();
    return dtos.map(AreaMapper.toDomain).toList();
  }

  @override
  Future<Area> createArea(String name, String? description) async {
    return AreaMapper.toDomain(await service.createArea(AreaMapper.toCreateRequest(name, description)));
  }

  @override
  Future<Area> deactivateArea(int id) async {
    return AreaMapper.toDomain(await service.deactivateArea(id));
  }
}
