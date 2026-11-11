/// Request type as returned by the API.
class RequestTypeDto {
  /// Creates the DTO.
  const RequestTypeDto({
    required this.id,
    required this.name,
    required this.description,
    required this.requiresAttachment,
    required this.balanceDeduction,
    required this.active,
    required this.fields,
  });

  /// Reads the DTO from its JSON.
  factory RequestTypeDto.fromJson(Map<String, dynamic> json) {
    final Object? fields = json['fields'];
    return RequestTypeDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      requiresAttachment: json['requiresAttachment'] as bool? ?? false,
      balanceDeduction: json['balanceDeduction'] as String? ?? 'NONE',
      active: json['active'] as bool? ?? false,
      fields: fields is List<dynamic>
          ? fields.map((dynamic item) => RequestFieldDto.fromJson(item as Map<String, dynamic>)).toList()
          : <RequestFieldDto>[],
    );
  }

  final int id;
  final String name;
  final String? description;
  final bool requiresAttachment;
  final String balanceDeduction;
  final bool active;
  final List<RequestFieldDto> fields;
}

/// Dynamic field of a request type.
class RequestFieldDto {
  /// Creates the DTO.
  const RequestFieldDto({
    required this.id,
    required this.key,
    required this.label,
    required this.dataType,
    required this.isRequired,
    required this.displayOrder,
  });

  /// Reads the DTO from its JSON.
  factory RequestFieldDto.fromJson(Map<String, dynamic> json) {
    return RequestFieldDto(
      id: (json['id'] as num).toInt(),
      key: json['key'] as String,
      label: json['label'] as String,
      dataType: json['dataType'] as String,
      isRequired: json['required'] as bool? ?? false,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    );
  }

  final int id;
  final String key;
  final String label;
  final String dataType;
  final bool isRequired;
  final int displayOrder;
}
