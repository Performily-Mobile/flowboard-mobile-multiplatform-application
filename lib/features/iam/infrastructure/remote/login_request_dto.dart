/// Body of the sign-in request.
class LoginRequestDto {
  /// Creates the DTO.
  const LoginRequestDto({required this.username, required this.password});

  final String username;
  final String password;

  /// JSON sent to the API.
  Map<String, dynamic> toJson() => <String, dynamic>{'username': username, 'password': password};
}
