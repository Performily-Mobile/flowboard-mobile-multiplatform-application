import 'package:flowboard/core/domain/file_reference.dart';
import 'package:flowboard/features/request/domain/entity/request_person.dart';
import 'package:flowboard/features/request/domain/valueobject/approver_type.dart';
import 'package:flowboard/features/request/domain/valueobject/request_period.dart';
import 'package:flowboard/features/request/domain/valueobject/request_status.dart';

/// Request of an employee (vacation, medical leave, hourly permission...).
///
/// [requester] and [approver] are filled from Workspace after the request is read.
class Request {
  /// Creates the request.
  const Request({
    required this.id,
    required this.requesterId,
    required this.requestTypeId,
    required this.requestTypeName,
    required this.status,
    required this.period,
    required this.requestedDays,
    required this.approverType,
    required this.approverEmployeeId,
    required this.submittedAt,
    required this.fieldValues,
    required this.attachments,
    required this.history,
    this.requester,
    this.approver,
  });

  final int id;
  final int requesterId;
  final int requestTypeId;
  final String requestTypeName;
  final RequestStatus status;
  final RequestPeriod? period;
  final int requestedDays;
  final ApproverType approverType;
  final int? approverEmployeeId;
  final DateTime submittedAt;
  final List<RequestFieldValue> fieldValues;
  final List<FileReference> attachments;
  final List<RequestHistoryEntry> history;
  final RequestPerson? requester;
  final RequestPerson? approver;

  /// True while the request waits for a decision.
  bool get isPending => status == RequestStatus.inProgress;

  /// True when the approver returned it to the requester.
  bool get isUnderReview => status == RequestStatus.underReview;

  /// True when it was approved, rejected or cancelled.
  bool get isResolved => status.isFinal;

  /// Name of who resolves the request.
  String get approverName => switch (approverType) {
        ApproverType.hrStaff => 'Recursos Humanos',
        ApproverType.directManager => approver?.name ?? 'Jefe directo',
      };

  /// Name of who sent the request.
  String get requesterName => requester?.name ?? 'Colaborador #$requesterId';

  /// Last history entry that led to the current status.
  RequestHistoryEntry? get lastChange {
    for (final RequestHistoryEntry entry in history.reversed) {
      if (entry.newStatus == status) return entry;
    }
    return null;
  }

  /// Last time the request was returned for review, with the comment of the approver.
  RequestHistoryEntry? get reviewComment {
    for (final RequestHistoryEntry entry in history.reversed) {
      if (entry.newStatus == RequestStatus.underReview) return entry;
    }
    return null;
  }

  /// Value of the dynamic field [key], or null.
  String? value(String key) {
    for (final RequestFieldValue fieldValue in fieldValues) {
      if (fieldValue.key == key) return fieldValue.value;
    }
    return null;
  }

  /// Copy with the people completed from Workspace.
  Request withPeople({
    required RequestPerson? requester,
    required RequestPerson? approver,
    required List<RequestHistoryEntry> history,
  }) {
    return Request(
      id: id,
      requesterId: requesterId,
      requestTypeId: requestTypeId,
      requestTypeName: requestTypeName,
      status: status,
      period: period,
      requestedDays: requestedDays,
      approverType: approverType,
      approverEmployeeId: approverEmployeeId,
      submittedAt: submittedAt,
      fieldValues: fieldValues,
      attachments: attachments,
      history: history,
      requester: requester,
      approver: approver,
    );
  }
}

/// Value written in one dynamic field of the request.
class RequestFieldValue {
  /// Creates the value.
  const RequestFieldValue({required this.key, required this.value});

  final String key;
  final String value;
}

/// Change of status of a request, with who made it and an optional comment.
class RequestHistoryEntry {
  /// Creates the entry.
  const RequestHistoryEntry({
    required this.id,
    required this.previousStatus,
    required this.newStatus,
    required this.actorId,
    required this.actorName,
    required this.comment,
    required this.occurredAt,
  });

  final int id;
  final RequestStatus? previousStatus;
  final RequestStatus newStatus;
  final int? actorId;
  final String? actorName;
  final String? comment;
  final DateTime occurredAt;

  /// Copy with the name of the actor.
  RequestHistoryEntry withActorName(String? name) {
    return RequestHistoryEntry(
      id: id,
      previousStatus: previousStatus,
      newStatus: newStatus,
      actorId: actorId,
      actorName: name,
      comment: comment,
      occurredAt: occurredAt,
    );
  }
}
