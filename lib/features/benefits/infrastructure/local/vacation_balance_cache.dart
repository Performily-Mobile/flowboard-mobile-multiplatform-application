import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flowboard/features/benefits/infrastructure/remote/vacation_balance_dto.dart';

/// Last vacation balance received for an employee, with the time it was fetched.
class CachedVacationBalance {
  /// Creates the cached copy.
  const CachedVacationBalance({required this.balance, required this.syncedAt});

  final VacationBalanceDto balance;
  final DateTime syncedAt;
}

/// Keeps on the phone the last vacation balance answer of each employee, to show it when there is
/// no connection (MA-57).
///
/// The Android app uses SharedPreferences; here each copy is a small JSON file in the private
/// support folder of the app, so no extra package is needed.
class VacationBalanceCache {
  /// Creates the cache.
  const VacationBalanceCache();

  static const String _directory = 'benefits-cache';

  /// Saves the [balance] of [employeeId] fetched at [syncedAt].
  Future<void> save(int employeeId, VacationBalanceDto balance, DateTime syncedAt) async {
    final File file = await _file(employeeId);
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(<String, dynamic>{
      'syncedAt': syncedAt.toIso8601String(),
      'balance': balance.toJson(),
    }));
  }

  /// Last saved balance of [employeeId], or null when there is none or it cannot be read.
  Future<CachedVacationBalance?> load(int employeeId) async {
    try {
      final File file = await _file(employeeId);
      if (!await file.exists()) return null;
      final Map<String, dynamic> json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return CachedVacationBalance(
        balance: VacationBalanceDto.fromJson(json['balance'] as Map<String, dynamic>),
        syncedAt: DateTime.parse(json['syncedAt'] as String),
      );
    } catch (_) {
      return null;
    }
  }

  Future<File> _file(int employeeId) async {
    final Directory base = await getApplicationSupportDirectory();
    return File('${base.path}/$_directory/vacation_balance_$employeeId.json');
  }
}
