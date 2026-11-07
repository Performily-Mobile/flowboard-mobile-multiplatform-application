import 'package:flowboard/core/network/api_client.dart';
import 'package:flowboard/features/benefits/infrastructure/remote/vacation_balance_dto.dart';

/// Endpoints of /vacation-balances (US41, US42).
class VacationBalanceService {
  /// Creates the service.
  const VacationBalanceService({required this.client});

  final ApiClient client;

  /// GET vacation-balances, optionally of one area.
  Future<List<VacationBalanceDto>> getBalances({int? areaId}) async {
    final List<dynamic> json =
        await client.get('vacation-balances', query: <String, dynamic>{'areaId': areaId}) as List<dynamic>;
    return json.map((dynamic item) => VacationBalanceDto.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// GET vacation-balances/me.
  Future<VacationBalanceDto> getMyBalance(int employeeId) async {
    final Object? json = await client.get('vacation-balances/me', query: <String, dynamic>{'employeeId': employeeId});
    return VacationBalanceDto.fromJson(json as Map<String, dynamic>);
  }

  /// GET vacation-balances/{employeeId}.
  Future<VacationBalanceDto> getBalance(int employeeId) async {
    return VacationBalanceDto.fromJson(await client.get('vacation-balances/$employeeId') as Map<String, dynamic>);
  }

  /// POST vacation-balances/{employeeId}/adjustments.
  Future<VacationBalanceDto> adjust(int employeeId, AdjustVacationBalanceRequestDto request) async {
    final Object? json = await client.post('vacation-balances/$employeeId/adjustments', body: request.toJson());
    return VacationBalanceDto.fromJson(json as Map<String, dynamic>);
  }
}
