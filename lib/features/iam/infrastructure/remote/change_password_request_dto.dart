/// Body of the password change request.
class ChangePasswordRequestDto {
  /// Creates the DTO.
  const ChangePasswordRequestDto({required this.currentPassword, required this.newPassword});

  final String currentPassword;
  final String newPassword;

  /// JSON sent to the API.
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'currentPassword': currentPassword, 'newPassword': newPassword};
}
