/// Area as returned by the API.
class AreaDto {
  /// Creates the DTO.
  const AreaDto({
    required this.id,
    required this.name,
    required this.description,
    required this.active,
    required this.activeEmployees,
  });

  /// Reads the DTO from its JSON.
  factory AreaDto.fromJson(Map<String, dynamic> json) {
    return AreaDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      active: json['active'] as bool,
      activeEmployees: (json['activeEmployees'] as num?)?.toInt() ?? 0,
    );
  }

  final int id;
  final String name;
  final String? description;
  final bool active;
  final int activeEmployees;
}
