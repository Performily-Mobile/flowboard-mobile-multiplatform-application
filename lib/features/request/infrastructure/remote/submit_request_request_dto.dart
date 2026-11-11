import 'package:flowboard/features/request/infrastructure/remote/request_dto.dart';

/// Body to send a new request.
class SubmitRequestRequestDto {
  /// Creates the body.
  const SubmitRequestRequestDto({
    required this.requesterId,
    required this.requestTypeId,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.fieldValues,
    required this.attachments,
  });

  final int requesterId;
  final int requestTypeId;
  final String? startDate;
  final String? endDate;
  final String? startTime;
  final String? endTime;
  final List<FieldValueDto> fieldValues;
  final List<RequestAttachmentDto> attachments;

  /// JSON of the body.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'requesterId': requesterId,
        'requestTypeId': requestTypeId,
        'startDate': startDate,
        'endDate': endDate,
        'startTime': startTime,
        'endTime': endTime,
        'fieldValues': fieldValues.map((FieldValueDto value) => value.toJson()).toList(),
        'attachments': attachments.map((RequestAttachmentDto file) => file.toJson()).toList(),
      };
}
