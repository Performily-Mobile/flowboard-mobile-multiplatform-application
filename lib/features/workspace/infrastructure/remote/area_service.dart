import 'package:flowboard/core/network/api_client.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/area_dto.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/create_area_request_dto.dart';

/// Endpoints of the areas.
class AreaService {
  /// Creates the service.
  const AreaService({required this.client});

  final ApiClient client;

  /// GET areas.
  Future<List<AreaDto>> getAreas() async {
    final List<dynamic> json = await client.get('areas') as List<dynamic>;
    return json.map((dynamic item) => AreaDto.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// POST areas.
  Future<AreaDto> createArea(CreateAreaRequestDto request) async {
    return AreaDto.fromJson(await client.post('areas', body: request.toJson()) as Map<String, dynamic>);
  }

  /// PATCH areas/{areaId}/deactivate.
  Future<AreaDto> deactivateArea(int areaId) async {
    return AreaDto.fromJson(await client.patch('areas/$areaId/deactivate') as Map<String, dynamic>);
  }
}
