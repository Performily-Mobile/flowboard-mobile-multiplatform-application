/// Body to rename an area.
class RenameAreaRequestDto {
  /// Creates the DTO.
  const RenameAreaRequestDto({required this.name});

  final String name;

  /// JSON sent to the API.
  Map<String, dynamic> toJson() => <String, dynamic>{'name': name};
}
