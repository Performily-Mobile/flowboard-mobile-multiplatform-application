import 'package:flowboard/features/request/infrastructure/remote/request_dto.dart';

/// Body to send again a request that was returned for review.
class ResubmitRequestRequestDto {
  /// Creates the body.
  const ResubmitRequestRequestDto({
    required this.actorId,
    required this.fieldValues,
    required this.attachments,
    required this.comment,
  });

  final int actorId;
  final List<FieldValueDto> fieldValues;
  final List<RequestAttachmentDto> attachments;
  final String? comment;

  /// JSON of the body.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'actorId': actorId,
        'fieldValues': fieldValues.map((FieldValueDto value) => value.toJson()).toList(),
        'attachments': attachments.map((RequestAttachmentDto file) => file.toJson()).toList(),
        'comment': comment,
      };
}
