import 'package:flowboard/core/domain/file_reference.dart';
import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/domain/entity/request_page.dart';
import 'package:flowboard/features/request/domain/repository/request_repository.dart';
import 'package:flowboard/features/request/domain/valueobject/request_period.dart';
import 'package:flowboard/features/request/domain/valueobject/request_sort_order.dart';
import 'package:flowboard/features/request/domain/valueobject/request_status.dart';
import 'package:flowboard/features/request/infrastructure/mapper/request_enum_mapper.dart';
import 'package:flowboard/features/request/infrastructure/mapper/request_mapper.dart';
import 'package:flowboard/features/request/infrastructure/remote/request_service.dart';

/// Requests read from and written to the Flowboard API.
class RequestRepositoryImpl implements RequestRepository {
  /// Creates the repository.
  const RequestRepositoryImpl({required this.service});

  final RequestService service;

  @override
  Future<RequestPage> getAll({
    List<RequestStatus> statuses = const <RequestStatus>[],
    int? approverId,
    int page = 0,
    int size = RequestPage.defaultSize,
  }) async {
    return RequestMapper.toPage(await service.getAll(
      statuses: statuses.map(RequestEnumMapper.toApi).toList(),
      approverId: approverId,
      page: page,
      size: size,
    ));
  }

  @override
  Future<RequestPage> getRequestsOf(
    int requesterId, {
    RequestStatus? status,
    int page = 0,
    int size = RequestPage.defaultSize,
  }) async {
    return RequestMapper.toPage(await service.getMyRequests(
      requesterId,
      status: status == null ? null : RequestEnumMapper.toApi(status),
      page: page,
      size: size,
    ));
  }

  @override
  Future<RequestPage> getPendingForApprover(
    int approverId, {
    int? requestTypeId,
    RequestSortOrder sort = RequestSortOrder.oldestFirst,
    int page = 0,
    int size = RequestPage.defaultSize,
  }) async {
    return RequestMapper.toPage(await service.getPendingForApprover(
      approverId,
      requestTypeId: requestTypeId,
      sort: RequestEnumMapper.toApi(sort),
      page: page,
      size: size,
    ));
  }

  @override
  Future<RequestPage> getPendingForHrStaff({
    int? requestTypeId,
    RequestSortOrder sort = RequestSortOrder.oldestFirst,
    int page = 0,
    int size = RequestPage.defaultSize,
  }) async {
    return RequestMapper.toPage(await service.getPendingForHrStaff(
      requestTypeId: requestTypeId,
      sort: RequestEnumMapper.toApi(sort),
      page: page,
      size: size,
    ));
  }

  @override
  Future<Request> getRequest(int requestId) async {
    return RequestMapper.toDomain(await service.getRequest(requestId));
  }

  @override
  Future<Request> submit({
    required int requesterId,
    required int requestTypeId,
    required RequestPeriod? period,
    required List<RequestFieldValue> fieldValues,
    required List<FileReference> attachments,
  }) async {
    return RequestMapper.toDomain(await service.submit(RequestMapper.toSubmitRequest(
      requesterId: requesterId,
      requestTypeId: requestTypeId,
      period: period,
      fieldValues: fieldValues,
      attachments: attachments,
    )));
  }

  @override
  Future<Request> approve(int requestId, int actorId) async {
    return RequestMapper.toDomain(await service.approve(requestId, RequestMapper.toResolveRequest(actorId)));
  }

  @override
  Future<Request> reject(int requestId, int actorId, String reason) async {
    return RequestMapper.toDomain(await service.reject(requestId, RequestMapper.toResolveRequest(actorId, reason)));
  }

  @override
  Future<Request> returnForReview(int requestId, int actorId, String comment) async {
    return RequestMapper.toDomain(
      await service.returnForReview(requestId, RequestMapper.toResolveRequest(actorId, comment)),
    );
  }

  @override
  Future<Request> resubmit({
    required int requestId,
    required int actorId,
    required List<RequestFieldValue> fieldValues,
    required List<FileReference> attachments,
    required String? comment,
  }) async {
    return RequestMapper.toDomain(await service.resubmit(
      requestId,
      RequestMapper.toResubmitRequest(
        actorId: actorId,
        fieldValues: fieldValues,
        attachments: attachments,
        comment: comment,
      ),
    ));
  }

  @override
  Future<Request> cancel(int requestId, int actorId) async {
    return RequestMapper.toDomain(await service.cancel(requestId, RequestMapper.toResolveRequest(actorId)));
  }
}
