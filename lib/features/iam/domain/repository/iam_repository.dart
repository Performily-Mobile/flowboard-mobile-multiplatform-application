import 'package:flowboard/features/iam/domain/entity/account.dart';
import 'package:flowboard/features/iam/domain/entity/auth_session.dart';
import 'package:flowboard/features/iam/domain/valueobject/account_role.dart';

/// Access to the accounts and sessions of the backend.
abstract class IamRepository {
  /// Signs in with [username] and [password] and returns the new session.
  Future<AuthSession> signIn({required String username, required String password});

  /// Changes the password of the signed-in account and returns the token of the new session.
  ///
  /// The backend revokes the previous token, so it must be replaced by the returned one.
  Future<String> changePassword({required String currentPassword, required String newPassword});

  /// Revokes the token of the signed-in account.
  Future<void> signOut();

  /// Accounts of every employee.
  Future<List<Account>> getAccounts();

  /// Gives [role] to the account [accountId] and returns the updated account.
  Future<Account> changeRole({required int accountId, required AccountRole role});

  /// Resets the password of the account [accountId] and returns the temporary password.
  Future<String> resetPassword(int accountId);
}
