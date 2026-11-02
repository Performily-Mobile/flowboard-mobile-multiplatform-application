/// Position as returned by the API.
class PositionDto {
  /// Creates the DTO.
  const PositionDto({
    required this.id,
    required this.title,
    required this.areaId,
    required this.areaName,
    required this.referenceSalaryAmount,
    required this.referenceSalaryCurrency,
    required this.active,
  });

  /// Reads the DTO from its JSON.
  factory PositionDto.fromJson(Map<String, dynamic> json) {
    return PositionDto(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      areaId: (json['areaId'] as num).toInt(),
      areaName: json['areaName'] as String?,
      referenceSalaryAmount: (json['referenceSalaryAmount'] as num).toDouble(),
      referenceSalaryCurrency: json['referenceSalaryCurrency'] as String?,
      active: json['active'] as bool,
    );
  }

  final int id;
  final String title;
  final int areaId;
  final String? areaName;
  final double referenceSalaryAmount;
  final String? referenceSalaryCurrency;
  final bool active;
}
