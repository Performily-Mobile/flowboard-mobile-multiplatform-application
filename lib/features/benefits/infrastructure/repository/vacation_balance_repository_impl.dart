import 'package:flowboard/core/network/api_exception.dart';
import 'package:flowboard/features/benefits/domain/entity/vacation_balance.dart';
import 'package:flowboard/features/benefits/domain/repository/vacation_balance_repository.dart';
import 'package:flowboard/features/benefits/domain/valueobject/adjustment_operation.dart';
import 'package:flowboard/features/benefits/infrastructure/local/vacation_balance_cache.dart';
import 'package:flowboard/features/benefits/infrastructure/mapper/vacation_balance_mapper.dart';
import 'package:flowboard/features/benefits/infrastructure/remote/vacation_balance_dto.dart';
import 'package:flowboard/features/benefits/infrastructure/remote/vacation_balance_service.dart';

/// Vacation balances read from the Flowboard API, with an offline copy of the own balance.
class VacationBalanceRepositoryImpl implements VacationBalanceRepository {
  /// Creates the repository.
  const VacationBalanceRepositoryImpl({required this.service, required this.cache});

  final VacationBalanceService service;
  final VacationBalanceCache cache;

  static final RegExp _httpErrorMessage = RegExp(r'^Error \d+$');

  /// Loads the balance of the signed-in employee.
  ///
  /// The local copy is saved only when the answer could be mapped. When there is no connection (or
  /// the server does not answer) the last saved copy is returned; otherwise the error is rethrown.
  @override
  Future<SyncedVacationBalance> getMyBalance(int employeeId) async {
    final VacationBalanceDto dto;
    try {
      dto = await service.getMyBalance(employeeId);
    } catch (error) {
      final CachedVacationBalance? cached = _isConnectionProblem(error) ? await cache.load(employeeId) : null;
      if (cached == null) rethrow;
      return SyncedVacationBalance(
        balance: VacationBalanceMapper.toDomain(cached.balance),
        syncedAt: cached.syncedAt,
        fromCache: true,
      );
    }
    final DateTime now = DateTime.now();
    final VacationBalance balance = VacationBalanceMapper.toDomain(dto);
    try {
      await cache.save(employeeId, dto, now);
    } catch (_) {
      // The copy is a convenience; failing to save it must not hide the fresh balance.
    }
    return SyncedVacationBalance(balance: balance, syncedAt: now, fromCache: false);
  }

  @override
  Future<List<VacationBalance>> getBalances({int? areaId}) async {
    final List<VacationBalanceDto> dtos = await service.getBalances(areaId: areaId);
    return dtos.map(VacationBalanceMapper.toDomain).toList();
  }

  @override
  Future<VacationBalance> getBalance(int employeeId) async {
    return VacationBalanceMapper.toDomain(await service.getBalance(employeeId));
  }

  @override
  Future<VacationBalance> adjust(
    int employeeId,
    AdjustmentOperation operation,
    double days,
    String reason,
    int authorId,
  ) async {
    final AdjustVacationBalanceRequestDto request =
        VacationBalanceMapper.toAdjustRequest(operation, days, reason, authorId);
    return VacationBalanceMapper.toDomain(await service.adjust(employeeId, request));
  }

  /// Tells whether [error] is a connectivity problem.
  ///
  /// Backend errors carry a code; network errors do not. An answer that does not come from the
  /// backend (such as "Error 502" from a proxy) has no code either, but the server did answer, so it
  /// is not treated as a lack of connection.
  bool _isConnectionProblem(Object error) {
    return error is ApiException && error.code == null && !_httpErrorMessage.hasMatch(error.message);
  }
}
