/// Body of the role change request.
class RoleChangeRequestDto {
  /// Creates the DTO.
  const RoleChangeRequestDto({required this.role});

  /// API name of the role, for example `HR_STAFF`.
  final String role;

  /// JSON sent to the API.
  Map<String, dynamic> toJson() => <String, dynamic>{'role': role};
}
