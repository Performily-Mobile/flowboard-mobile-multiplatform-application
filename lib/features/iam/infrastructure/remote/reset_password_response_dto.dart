/// Temporary password returned by the API after a password reset.
class ResetPasswordResponseDto {
  /// Creates the DTO.
  const ResetPasswordResponseDto({required this.temporaryPassword});

  /// Reads the DTO from its JSON.
  factory ResetPasswordResponseDto.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponseDto(temporaryPassword: json['temporaryPassword'] as String? ?? '');
  }

  final String temporaryPassword;
}
