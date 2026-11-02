import 'package:flowboard/core/network/api_client.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/create_position_request_dto.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/position_dto.dart';

/// Endpoints of the positions.
class PositionService {
  /// Creates the service.
  const PositionService({required this.client});

  final ApiClient client;

  /// GET positions?areaId=.
  Future<List<PositionDto>> getPositions(int? areaId) async {
    final List<dynamic> json =
        await client.get('positions', query: <String, dynamic>{'areaId': areaId}) as List<dynamic>;
    return json.map((dynamic item) => PositionDto.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// POST positions.
  Future<PositionDto> createPosition(CreatePositionRequestDto request) async {
    return PositionDto.fromJson(await client.post('positions', body: request.toJson()) as Map<String, dynamic>);
  }
}
