import 'package:flowboard/features/iam/domain/entity/account.dart';
import 'package:flowboard/features/iam/domain/entity/auth_session.dart';
import 'package:flowboard/features/iam/domain/repository/iam_repository.dart';
import 'package:flowboard/features/iam/domain/valueobject/account_role.dart';
import 'package:flowboard/features/iam/infrastructure/mapper/iam_mapper.dart';
import 'package:flowboard/features/iam/infrastructure/remote/account_dto.dart';
import 'package:flowboard/features/iam/infrastructure/remote/change_password_request_dto.dart';
import 'package:flowboard/features/iam/infrastructure/remote/iam_service.dart';
import 'package:flowboard/features/iam/infrastructure/remote/login_request_dto.dart';
import 'package:flowboard/features/iam/infrastructure/remote/login_response_dto.dart';
import 'package:flowboard/features/iam/infrastructure/remote/reset_password_response_dto.dart';
import 'package:flowboard/features/iam/infrastructure/remote/role_change_request_dto.dart';

/// [IamRepository] backed by the IAM endpoints of the backend.
class IamRepositoryImpl implements IamRepository {
  /// Creates the repository.
  const IamRepositoryImpl({required this.service});

  final IamService service;

  @override
  Future<AuthSession> signIn({required String username, required String password}) async {
    final LoginResponseDto dto = await service.login(LoginRequestDto(username: username, password: password));
    return IamMapper.toSession(dto, username: username);
  }

  @override
  Future<String> changePassword({required String currentPassword, required String newPassword}) async {
    final LoginResponseDto dto = await service.changePassword(
      ChangePasswordRequestDto(currentPassword: currentPassword, newPassword: newPassword),
    );
    return dto.token;
  }

  @override
  Future<void> signOut() => service.logout();

  @override
  Future<List<Account>> getAccounts() async {
    final List<AccountDto> accounts = await service.getAccounts();
    return accounts.map(IamMapper.toAccount).toList();
  }

  @override
  Future<Account> changeRole({required int accountId, required AccountRole role}) async {
    final AccountDto dto = await service.changeRole(
      accountId,
      RoleChangeRequestDto(role: IamMapper.roleToApi(role)),
    );
    return IamMapper.toAccount(dto);
  }

  @override
  Future<String> resetPassword(int accountId) async {
    final ResetPasswordResponseDto dto = await service.resetPassword(accountId);
    return dto.temporaryPassword;
  }
}
