/// Body to create a request type.
class CreateRequestTypeRequestDto {
  /// Creates the body.
  const CreateRequestTypeRequestDto({
    required this.name,
    required this.description,
    required this.requiresAttachment,
    required this.balanceDeduction,
    required this.fields,
  });

  final String name;
  final String? description;
  final bool requiresAttachment;
  final String balanceDeduction;
  final List<CreateRequestFieldRequestDto> fields;

  /// JSON of the body.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'description': description,
        'requiresAttachment': requiresAttachment,
        'balanceDeduction': balanceDeduction,
        'fields': fields.map((CreateRequestFieldRequestDto field) => field.toJson()).toList(),
      };
}

/// Field of the body to create a request type.
class CreateRequestFieldRequestDto {
  /// Creates the field.
  const CreateRequestFieldRequestDto({
    required this.key,
    required this.label,
    required this.dataType,
    required this.isRequired,
    required this.displayOrder,
  });

  final String key;
  final String label;
  final String dataType;
  final bool isRequired;
  final int displayOrder;

  /// JSON of the field.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'key': key,
        'label': label,
        'dataType': dataType,
        'required': isRequired,
        'displayOrder': displayOrder,
      };
}
