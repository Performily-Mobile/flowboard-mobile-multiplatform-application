import 'package:flowboard/core/domain/file_reference.dart';
import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/domain/entity/request_page.dart';
import 'package:flowboard/features/request/domain/valueobject/request_period.dart';
import 'package:flowboard/features/request/domain/valueobject/request_sort_order.dart';
import 'package:flowboard/features/request/domain/valueobject/request_status.dart';

/// Repository of the requests.
abstract class RequestRepository {
  /// One page of the requests of every employee, filtered by [statuses] and [approverId].
  Future<RequestPage> getAll({
    List<RequestStatus> statuses = const <RequestStatus>[],
    int? approverId,
    int page = 0,
    int size = RequestPage.defaultSize,
  });

  /// One page of the requests sent by [requesterId], optionally with a [status].
  Future<RequestPage> getRequestsOf(
    int requesterId, {
    RequestStatus? status,
    int page = 0,
    int size = RequestPage.defaultSize,
  });

  /// One page of the pending requests that the direct manager [approverId] has to resolve.
  Future<RequestPage> getPendingForApprover(
    int approverId, {
    int? requestTypeId,
    RequestSortOrder sort = RequestSortOrder.oldestFirst,
    int page = 0,
    int size = RequestPage.defaultSize,
  });

  /// One page of the pending requests of the HR inbox.
  Future<RequestPage> getPendingForHrStaff({
    int? requestTypeId,
    RequestSortOrder sort = RequestSortOrder.oldestFirst,
    int page = 0,
    int size = RequestPage.defaultSize,
  });

  /// Request [requestId].
  Future<Request> getRequest(int requestId);

  /// Sends a new request.
  Future<Request> submit({
    required int requesterId,
    required int requestTypeId,
    required RequestPeriod? period,
    required List<RequestFieldValue> fieldValues,
    required List<FileReference> attachments,
  });

  /// Approves the request.
  Future<Request> approve(int requestId, int actorId);

  /// Rejects the request with a [reason].
  Future<Request> reject(int requestId, int actorId, String reason);

  /// Returns the request to its requester with a [comment].
  Future<Request> returnForReview(int requestId, int actorId, String comment);

  /// Sends again a request that was returned for review.
  Future<Request> resubmit({
    required int requestId,
    required int actorId,
    required List<RequestFieldValue> fieldValues,
    required List<FileReference> attachments,
    required String? comment,
  });

  /// Cancels the request.
  Future<Request> cancel(int requestId, int actorId);
}
