import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/features/iam/domain/entity/account.dart';
import 'package:flowboard/features/iam/domain/entity/auth_session.dart';
import 'package:flowboard/features/iam/domain/valueobject/account_role.dart';
import 'package:flowboard/features/iam/domain/valueobject/account_status.dart';
import 'package:flowboard/features/iam/infrastructure/remote/account_dto.dart';
import 'package:flowboard/features/iam/infrastructure/remote/login_response_dto.dart';

/// Converts the DTOs of the IAM API to domain objects and back.
class IamMapper {
  const IamMapper._();

  static const String _humanResourcesRole = 'HR_STAFF';
  static const String _employeeRole = 'EMPLOYEE';
  static const String _activeStatus = 'ACTIVE';

  /// Session of [dto] for the account [username].
  static AuthSession toSession(LoginResponseDto dto, {required String username}) {
    return AuthSession(
      token: dto.token,
      role: roleFromApi(dto.role),
      employeeId: EmployeeId(dto.employeeId),
      mustChangePassword: dto.mustChangePassword,
      username: username,
    );
  }

  /// Account of [dto].
  static Account toAccount(AccountDto dto) {
    return Account(
      id: dto.id,
      employeeId: EmployeeId(dto.employeeId),
      username: dto.username,
      role: roleFromApi(dto.role),
      status: dto.status == _activeStatus ? AccountStatus.active : AccountStatus.disabled,
      mustChangePassword: dto.mustChangePassword,
    );
  }

  /// API name of [role].
  static String roleToApi(AccountRole role) {
    return switch (role) {
      AccountRole.humanResources => _humanResourcesRole,
      AccountRole.employee => _employeeRole,
    };
  }

  /// Role of the API name [raw]; an unknown name gives the employee role, the one with fewer
  /// permissions.
  static AccountRole roleFromApi(String raw) {
    return raw == _humanResourcesRole ? AccountRole.humanResources : AccountRole.employee;
  }
}
