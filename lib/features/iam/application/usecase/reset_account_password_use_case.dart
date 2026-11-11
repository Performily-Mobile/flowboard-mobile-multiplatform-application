import 'package:flowboard/features/iam/domain/entity/account.dart';
import 'package:flowboard/features/iam/domain/repository/iam_repository.dart';

/// Resets the password of the account of an employee and gets a temporary one.
class ResetAccountPasswordUseCase {
  /// Creates the use case.
  const ResetAccountPasswordUseCase({required this.repository});

  final IamRepository repository;

  /// Temporary password of [account]; throws [ArgumentError] when the account is disabled.
  Future<String> execute(Account account) {
    if (!account.canBeManaged) {
      throw ArgumentError('Solo se puede restablecer la contraseña de una cuenta activa.');
    }
    return repository.resetPassword(account.id);
  }
}
