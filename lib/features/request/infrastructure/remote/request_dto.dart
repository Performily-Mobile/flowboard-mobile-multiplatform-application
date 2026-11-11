/// Request as returned by the API.
class RequestDto {
  /// Creates the DTO.
  const RequestDto({
    required this.id,
    required this.requesterId,
    required this.requestTypeId,
    required this.requestTypeName,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.requestedDays,
    required this.approverType,
    required this.approverEmployeeId,
    required this.submittedAt,
    required this.fieldValues,
    required this.attachments,
    required this.history,
  });

  /// Reads the DTO from its JSON.
  factory RequestDto.fromJson(Map<String, dynamic> json) {
    return RequestDto(
      id: (json['id'] as num).toInt(),
      requesterId: (json['requesterId'] as num).toInt(),
      requestTypeId: (json['requestTypeId'] as num).toInt(),
      requestTypeName: json['requestTypeName'] as String?,
      status: json['status'] as String,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      requestedDays: (json['requestedDays'] as num?)?.toInt() ?? 0,
      approverType: json['approverType'] as String,
      approverEmployeeId: (json['approverEmployeeId'] as num?)?.toInt(),
      submittedAt: json['submittedAt'] as String?,
      fieldValues: _list(json['fieldValues'], FieldValueDto.fromJson),
      attachments: _list(json['attachments'], RequestAttachmentDto.fromJson),
      history: _list(json['history'], RequestHistoryDto.fromJson),
    );
  }

  final int id;
  final int requesterId;
  final int requestTypeId;
  final String? requestTypeName;
  final String status;
  final String? startDate;
  final String? endDate;
  final String? startTime;
  final String? endTime;
  final int requestedDays;
  final String approverType;
  final int? approverEmployeeId;
  final String? submittedAt;
  final List<FieldValueDto> fieldValues;
  final List<RequestAttachmentDto> attachments;
  final List<RequestHistoryDto> history;

  static List<T> _list<T>(Object? raw, T Function(Map<String, dynamic> json) read) {
    if (raw is! List<dynamic>) return <T>[];
    return raw.map((dynamic item) => read(item as Map<String, dynamic>)).toList();
  }
}

/// Value of one dynamic field of a request.
class FieldValueDto {
  /// Creates the DTO.
  const FieldValueDto({required this.key, required this.value});

  /// Reads the DTO from its JSON.
  factory FieldValueDto.fromJson(Map<String, dynamic> json) {
    return FieldValueDto(key: json['key'] as String, value: json['value'] as String?);
  }

  final String key;
  final String? value;

  /// JSON body of the value.
  Map<String, dynamic> toJson() => <String, dynamic>{'key': key, 'value': value};
}

/// File attached to a request.
class RequestAttachmentDto {
  /// Creates the DTO.
  const RequestAttachmentDto({
    required this.fileName,
    required this.contentType,
    required this.sizeInBytes,
    required this.storageUrl,
  });

  /// Reads the DTO from its JSON.
  factory RequestAttachmentDto.fromJson(Map<String, dynamic> json) {
    return RequestAttachmentDto(
      fileName: json['fileName'] as String,
      contentType: json['contentType'] as String,
      sizeInBytes: (json['sizeInBytes'] as num?)?.toInt(),
      storageUrl: json['storageUrl'] as String,
    );
  }

  final String fileName;
  final String contentType;
  final int? sizeInBytes;
  final String storageUrl;

  /// JSON body of the attachment.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'fileName': fileName,
        'contentType': contentType,
        'sizeInBytes': sizeInBytes,
        'storageUrl': storageUrl,
      };
}

/// Change of status registered in the history of a request.
class RequestHistoryDto {
  /// Creates the DTO.
  const RequestHistoryDto({
    required this.id,
    required this.previousStatus,
    required this.newStatus,
    required this.actorId,
    required this.comment,
    required this.occurredAt,
  });

  /// Reads the DTO from its JSON.
  factory RequestHistoryDto.fromJson(Map<String, dynamic> json) {
    return RequestHistoryDto(
      id: (json['id'] as num).toInt(),
      previousStatus: json['previousStatus'] as String?,
      newStatus: json['newStatus'] as String,
      actorId: (json['actorId'] as num?)?.toInt(),
      comment: json['comment'] as String?,
      occurredAt: json['occurredAt'] as String?,
    );
  }

  final int id;
  final String? previousStatus;
  final String newStatus;
  final int? actorId;
  final String? comment;
  final String? occurredAt;
}
