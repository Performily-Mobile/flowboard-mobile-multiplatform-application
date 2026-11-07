/// Benefit type as returned by the API.
class BenefitTypeDto {
  /// Creates the DTO.
  const BenefitTypeDto({
    required this.id,
    required this.name,
    required this.description,
    required this.unit,
    required this.hasBalance,
    required this.active,
  });

  /// Reads the DTO from its JSON.
  factory BenefitTypeDto.fromJson(Map<String, dynamic> json) {
    return BenefitTypeDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      unit: json['unit'] as String,
      hasBalance: json['hasBalance'] as bool? ?? false,
      active: json['active'] as bool? ?? false,
    );
  }

  final int id;
  final String name;
  final String? description;
  final String unit;
  final bool hasBalance;
  final bool active;
}

/// Body to create a benefit type.
class CreateBenefitTypeRequestDto {
  /// Creates the DTO.
  const CreateBenefitTypeRequestDto({
    required this.name,
    required this.description,
    required this.hasBalance,
    required this.unit,
  });

  final String name;
  final String? description;
  final bool hasBalance;
  final String unit;

  /// JSON sent to the API.
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'name': name, 'description': description, 'hasBalance': hasBalance, 'unit': unit};
}
