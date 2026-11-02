/// Body to create an area.
class CreateAreaRequestDto {
  /// Creates the DTO.
  const CreateAreaRequestDto({required this.name, required this.description});

  final String name;
  final String? description;

  /// JSON sent to the API.
  Map<String, dynamic> toJson() => <String, dynamic>{'name': name, 'description': description};
}
