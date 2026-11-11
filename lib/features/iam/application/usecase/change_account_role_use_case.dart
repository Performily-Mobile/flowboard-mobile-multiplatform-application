import 'package:flowboard/features/iam/domain/entity/account.dart';
import 'package:flowboard/features/iam/domain/repository/iam_repository.dart';
import 'package:flowboard/features/iam/domain/valueobject/account_role.dart';

/// Gives a new role to the account of an employee.
class ChangeAccountRoleUseCase {
  /// Creates the use case.
  const ChangeAccountRoleUseCase({required this.repository});

  final IamRepository repository;

  /// Gives [role] to [account] and returns the updated account; throws [ArgumentError] when the
  /// account is disabled.
  Future<Account> execute({required Account account, required AccountRole role}) async {
    if (!account.canBeManaged) {
      throw ArgumentError('Solo se puede cambiar el rol de una cuenta activa.');
    }
    if (account.role == role) return account;
    return repository.changeRole(accountId: account.id, role: role);
  }
}
