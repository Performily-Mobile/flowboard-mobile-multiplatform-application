import 'package:flowboard/core/network/api_client.dart';
import 'package:flowboard/features/iam/infrastructure/remote/account_dto.dart';
import 'package:flowboard/features/iam/infrastructure/remote/change_password_request_dto.dart';
import 'package:flowboard/features/iam/infrastructure/remote/login_request_dto.dart';
import 'package:flowboard/features/iam/infrastructure/remote/login_response_dto.dart';
import 'package:flowboard/features/iam/infrastructure/remote/reset_password_response_dto.dart';
import 'package:flowboard/features/iam/infrastructure/remote/role_change_request_dto.dart';

/// Endpoints of sign in, passwords and accounts.
class IamService {
  /// Creates the service.
  const IamService({required this.client});

  final ApiClient client;

  /// POST auth/login.
  Future<LoginResponseDto> login(LoginRequestDto request) async {
    return _session(await client.post('auth/login', body: request.toJson()));
  }

  /// POST auth/change-password; the previous token stops working.
  Future<LoginResponseDto> changePassword(ChangePasswordRequestDto request) async {
    return _session(await client.post('auth/change-password', body: request.toJson()));
  }

  /// POST auth/logout; revokes the token sent in the request.
  Future<void> logout() async {
    await client.post('auth/logout');
  }

  /// GET accounts; only for the HR staff.
  Future<List<AccountDto>> getAccounts() async {
    final List<dynamic> json = await client.get('accounts') as List<dynamic>;
    return json.map((dynamic item) => AccountDto.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// PATCH accounts/{accountId}/role; only for the HR staff.
  Future<AccountDto> changeRole(int accountId, RoleChangeRequestDto request) async {
    final dynamic json = await client.patch('accounts/$accountId/role', body: request.toJson());
    return AccountDto.fromJson(json as Map<String, dynamic>);
  }

  /// POST accounts/{accountId}/reset-password; only for the HR staff.
  Future<ResetPasswordResponseDto> resetPassword(int accountId) async {
    final dynamic json = await client.post('accounts/$accountId/reset-password');
    return ResetPasswordResponseDto.fromJson(json as Map<String, dynamic>);
  }

  LoginResponseDto _session(dynamic json) => LoginResponseDto.fromJson(json as Map<String, dynamic>);
}
