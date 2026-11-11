/// Account of an employee as returned by the API.
class AccountDto {
  /// Creates the DTO.
  const AccountDto({
    required this.id,
    required this.employeeId,
    required this.username,
    required this.role,
    required this.status,
    required this.mustChangePassword,
  });

  /// Reads the DTO from its JSON.
  factory AccountDto.fromJson(Map<String, dynamic> json) {
    return AccountDto(
      id: (json['id'] as num).toInt(),
      employeeId: (json['employeeId'] as num).toInt(),
      username: json['username'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      mustChangePassword: json['mustChangePassword'] as bool? ?? false,
    );
  }

  final int id;
  final int employeeId;
  final String username;
  final String role;
  final String status;
  final bool mustChangePassword;
}
