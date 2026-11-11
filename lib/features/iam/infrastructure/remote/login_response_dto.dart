/// Session returned by the API after signing in or changing the password.
class LoginResponseDto {
  /// Creates the DTO.
  const LoginResponseDto({
    required this.token,
    required this.role,
    required this.employeeId,
    required this.mustChangePassword,
  });

  /// Reads the DTO from its JSON.
  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      token: json['token'] as String,
      role: json['role'] as String,
      employeeId: (json['employeeId'] as num).toInt(),
      mustChangePassword: json['mustChangePassword'] as bool? ?? false,
    );
  }

  final String token;
  final String role;
  final int employeeId;
  final bool mustChangePassword;
}
