import 'package:flowboard/core/network/api_client.dart';
import 'package:flowboard/features/request/infrastructure/remote/create_request_type_request_dto.dart';
import 'package:flowboard/features/request/infrastructure/remote/request_type_dto.dart';

/// Endpoints of the request types.
class RequestTypeService {
  /// Creates the service.
  const RequestTypeService({required this.client});

  final ApiClient client;

  /// GET request-types?activeOnly=.
  Future<List<RequestTypeDto>> getRequestTypes({required bool activeOnly}) async {
    final List<dynamic> json =
        await client.get('request-types', query: <String, dynamic>{'activeOnly': activeOnly}) as List<dynamic>;
    return json.map((dynamic item) => RequestTypeDto.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// POST request-types.
  Future<RequestTypeDto> createRequestType(CreateRequestTypeRequestDto request) async {
    return _one(await client.post('request-types', body: request.toJson()));
  }

  /// PATCH request-types/{requestTypeId}/activate.
  Future<RequestTypeDto> activate(int requestTypeId) async {
    return _one(await client.patch('request-types/$requestTypeId/activate'));
  }

  /// PATCH request-types/{requestTypeId}/deactivate.
  Future<RequestTypeDto> deactivate(int requestTypeId) async {
    return _one(await client.patch('request-types/$requestTypeId/deactivate'));
  }

  /// DELETE request-types/{requestTypeId}; it only works when the type has no requests.
  Future<void> delete(int requestTypeId) async {
    await client.delete('request-types/$requestTypeId');
  }

  RequestTypeDto _one(dynamic json) => RequestTypeDto.fromJson(json as Map<String, dynamic>);
}
