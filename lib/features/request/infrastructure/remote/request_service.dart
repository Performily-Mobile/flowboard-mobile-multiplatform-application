import 'package:flowboard/core/network/api_client.dart';
import 'package:flowboard/features/request/infrastructure/remote/request_dto.dart';
import 'package:flowboard/features/request/infrastructure/remote/request_page_dto.dart';
import 'package:flowboard/features/request/infrastructure/remote/resolve_request_request_dto.dart';
import 'package:flowboard/features/request/infrastructure/remote/resubmit_request_request_dto.dart';
import 'package:flowboard/features/request/infrastructure/remote/submit_request_request_dto.dart';

/// Endpoints of the requests.
class RequestService {
  /// Creates the service.
  const RequestService({required this.client});

  final ApiClient client;

  /// POST requests.
  Future<RequestDto> submit(SubmitRequestRequestDto request) async {
    return _one(await client.post('requests', body: request.toJson()));
  }

  /// GET requests?status=&approverId=&page=&size=; several statuses go separated by commas.
  Future<RequestPageDto> getAll({
    List<String> statuses = const <String>[],
    int? approverId,
    required int page,
    required int size,
  }) async {
    return _page(await client.get('requests', query: <String, dynamic>{
      'status': statuses.isEmpty ? null : statuses.join(','),
      'approverId': approverId,
      'page': page,
      'size': size,
    }));
  }

  /// GET requests/me?requesterId=&status=&page=&size=.
  Future<RequestPageDto> getMyRequests(int requesterId, {String? status, required int page, required int size}) async {
    return _page(await client.get('requests/me', query: <String, dynamic>{
      'requesterId': requesterId,
      'status': status,
      'page': page,
      'size': size,
    }));
  }

  /// GET requests/pending-approval?approverId=&requestTypeId=&sort=&page=&size=.
  Future<RequestPageDto> getPendingForApprover(
    int approverId, {
    int? requestTypeId,
    required String sort,
    required int page,
    required int size,
  }) async {
    return _page(await client.get('requests/pending-approval', query: <String, dynamic>{
      'approverId': approverId,
      'requestTypeId': requestTypeId,
      'sort': sort,
      'page': page,
      'size': size,
    }));
  }

  /// GET requests/pending-approval/hr-staff?requestTypeId=&sort=&page=&size=.
  Future<RequestPageDto> getPendingForHrStaff({
    int? requestTypeId,
    required String sort,
    required int page,
    required int size,
  }) async {
    return _page(await client.get('requests/pending-approval/hr-staff', query: <String, dynamic>{
      'requestTypeId': requestTypeId,
      'sort': sort,
      'page': page,
      'size': size,
    }));
  }

  /// GET requests/{requestId}.
  Future<RequestDto> getRequest(int requestId) async {
    return _one(await client.get('requests/$requestId'));
  }

  /// POST requests/{requestId}/approve.
  Future<RequestDto> approve(int requestId, ResolveRequestRequestDto request) async {
    return _one(await client.post('requests/$requestId/approve', body: request.toJson()));
  }

  /// POST requests/{requestId}/reject.
  Future<RequestDto> reject(int requestId, ResolveRequestRequestDto request) async {
    return _one(await client.post('requests/$requestId/reject', body: request.toJson()));
  }

  /// POST requests/{requestId}/return-for-review.
  Future<RequestDto> returnForReview(int requestId, ResolveRequestRequestDto request) async {
    return _one(await client.post('requests/$requestId/return-for-review', body: request.toJson()));
  }

  /// POST requests/{requestId}/resubmit.
  Future<RequestDto> resubmit(int requestId, ResubmitRequestRequestDto request) async {
    return _one(await client.post('requests/$requestId/resubmit', body: request.toJson()));
  }

  /// POST requests/{requestId}/cancel.
  Future<RequestDto> cancel(int requestId, ResolveRequestRequestDto request) async {
    return _one(await client.post('requests/$requestId/cancel', body: request.toJson()));
  }

  RequestDto _one(dynamic json) => RequestDto.fromJson(json as Map<String, dynamic>);

  RequestPageDto _page(dynamic json) => RequestPageDto.fromJson(json as Map<String, dynamic>);
}
