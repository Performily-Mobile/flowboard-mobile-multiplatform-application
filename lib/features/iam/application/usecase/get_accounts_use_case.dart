import 'package:flowboard/features/iam/domain/entity/account.dart';
import 'package:flowboard/features/iam/domain/repository/iam_repository.dart';

/// Gets the accounts of every employee, sorted by e-mail.
class GetAccountsUseCase {
  /// Creates the use case.
  const GetAccountsUseCase({required this.repository});

  final IamRepository repository;

  /// Accounts sorted by e-mail.
  Future<List<Account>> execute() async {
    final List<Account> accounts = await repository.getAccounts();
    return accounts.toList()
      ..sort((Account a, Account b) => a.username.toLowerCase().compareTo(b.username.toLowerCase()));
  }
}
