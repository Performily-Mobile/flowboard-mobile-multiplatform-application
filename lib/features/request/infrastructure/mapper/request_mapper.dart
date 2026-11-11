import 'package:flowboard/core/domain/file_reference.dart';
import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/domain/entity/request_page.dart';
import 'package:flowboard/features/request/domain/valueobject/approver_type.dart';
import 'package:flowboard/features/request/domain/valueobject/request_period.dart';
import 'package:flowboard/features/request/domain/valueobject/request_status.dart';
import 'package:flowboard/features/request/domain/valueobject/request_time.dart';
import 'package:flowboard/features/request/infrastructure/mapper/request_date_mapper.dart';
import 'package:flowboard/features/request/infrastructure/mapper/request_enum_mapper.dart';
import 'package:flowboard/features/request/infrastructure/remote/request_dto.dart';
import 'package:flowboard/features/request/infrastructure/remote/request_page_dto.dart';
import 'package:flowboard/features/request/infrastructure/remote/resolve_request_request_dto.dart';
import 'package:flowboard/features/request/infrastructure/remote/resubmit_request_request_dto.dart';
import 'package:flowboard/features/request/infrastructure/remote/submit_request_request_dto.dart';

/// Translates the requests between the API and the domain.
class RequestMapper {
  const RequestMapper._();

  /// Domain page of [dto].
  static RequestPage toPage(RequestPageDto dto) {
    return RequestPage(
      items: dto.items.map(toDomain).toList(),
      page: dto.page,
      size: dto.size,
      totalItems: dto.totalItems,
      totalPages: dto.totalPages,
      hasNext: dto.hasNext,
    );
  }

  /// Domain request of [dto].
  static Request toDomain(RequestDto dto) {
    final List<RequestHistoryEntry> history = dto.history.map(_toHistoryEntry).toList()
      ..sort((RequestHistoryEntry a, RequestHistoryEntry b) {
        final int byDate = a.occurredAt.compareTo(b.occurredAt);
        return byDate != 0 ? byDate : a.id.compareTo(b.id);
      });
    return Request(
      id: dto.id,
      requesterId: dto.requesterId,
      requestTypeId: dto.requestTypeId,
      requestTypeName: dto.requestTypeName ?? '',
      status: _status(dto.status),
      period: _period(dto),
      requestedDays: dto.requestedDays,
      approverType: RequestEnumMapper.fromApi(ApproverType.values, dto.approverType, ApproverType.directManager),
      approverEmployeeId: dto.approverEmployeeId,
      submittedAt: RequestDateMapper.parseDateTime(dto.submittedAt) ?? DateTime.fromMillisecondsSinceEpoch(0),
      fieldValues: dto.fieldValues
          .where((FieldValueDto value) => value.value != null && value.value!.trim().isNotEmpty)
          .map((FieldValueDto value) => RequestFieldValue(key: value.key, value: value.value!))
          .toList(),
      attachments: dto.attachments.map(_toFile).whereType<FileReference>().toList(),
      history: history,
    );
  }

  /// Body to send a new request.
  static SubmitRequestRequestDto toSubmitRequest({
    required int requesterId,
    required int requestTypeId,
    required RequestPeriod? period,
    required List<RequestFieldValue> fieldValues,
    required List<FileReference> attachments,
  }) {
    return SubmitRequestRequestDto(
      requesterId: requesterId,
      requestTypeId: requestTypeId,
      startDate: period == null ? null : RequestDateMapper.formatDate(period.startDate),
      endDate: period == null ? null : RequestDateMapper.formatDate(period.endDate),
      startTime: period?.startTime?.format(),
      endTime: period?.endTime?.format(),
      fieldValues: fieldValues.map(_toFieldValueDto).toList(),
      attachments: attachments.map(_toAttachmentDto).toList(),
    );
  }

  /// Body to approve, reject, return or cancel a request.
  static ResolveRequestRequestDto toResolveRequest(int actorId, [String? comment]) {
    return ResolveRequestRequestDto(actorId: actorId, comment: comment);
  }

  /// Body to resubmit a request.
  static ResubmitRequestRequestDto toResubmitRequest({
    required int actorId,
    required List<RequestFieldValue> fieldValues,
    required List<FileReference> attachments,
    required String? comment,
  }) {
    return ResubmitRequestRequestDto(
      actorId: actorId,
      fieldValues: fieldValues.map(_toFieldValueDto).toList(),
      attachments: attachments.map(_toAttachmentDto).toList(),
      comment: comment,
    );
  }

  static RequestStatus _status(String? raw) =>
      RequestEnumMapper.fromApi(RequestStatus.values, raw, RequestStatus.inProgress);

  /// Period of the request, or null when it has no valid dates.
  static RequestPeriod? _period(RequestDto dto) {
    final DateTime? start = RequestDateMapper.parseDate(dto.startDate);
    final DateTime? end = RequestDateMapper.parseDate(dto.endDate);
    if (start == null || end == null) return null;
    final RequestTime? startTime = RequestDateMapper.parseTime(dto.startTime);
    final RequestTime? endTime = RequestDateMapper.parseTime(dto.endTime);
    try {
      return RequestPeriod(startDate: start, endDate: end, startTime: startTime, endTime: endTime);
    } on ArgumentError {
      return null;
    }
  }

  static RequestHistoryEntry _toHistoryEntry(RequestHistoryDto dto) {
    final String? comment = dto.comment;
    final String? previous = dto.previousStatus;
    return RequestHistoryEntry(
      id: dto.id,
      previousStatus: previous == null ? null : _status(previous),
      newStatus: _status(dto.newStatus),
      actorId: dto.actorId,
      actorName: null,
      comment: comment == null || comment.trim().isEmpty ? null : comment,
      occurredAt: RequestDateMapper.parseDateTime(dto.occurredAt) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  /// File of [dto], or null when it is not valid. A missing size is read as 1 byte.
  static FileReference? _toFile(RequestAttachmentDto dto) {
    try {
      return FileReference(
        fileName: dto.fileName,
        contentType: dto.contentType,
        sizeInBytes: dto.sizeInBytes ?? 1,
        storageUrl: dto.storageUrl,
      );
    } on ArgumentError {
      return null;
    }
  }

  static FieldValueDto _toFieldValueDto(RequestFieldValue value) => FieldValueDto(key: value.key, value: value.value);

  static RequestAttachmentDto _toAttachmentDto(FileReference file) {
    return RequestAttachmentDto(
      fileName: file.fileName,
      contentType: file.contentType,
      sizeInBytes: file.sizeInBytes,
      storageUrl: file.storageUrl,
    );
  }
}
