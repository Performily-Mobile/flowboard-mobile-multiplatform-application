import 'package:flowboard/core/network/api_client.dart';

/// Vacation balances, read from the Benefits backend; only the available days are kept.
class DashboardVacationService {
  /// Creates the service.
  const DashboardVacationService({required this.client});

  final ApiClient client;

  /// GET vacation-balances: the available days of every employee.
  Future<List<double>> getAvailableDays() async {
    final List<dynamic> json = await client.get('vacation-balances') as List<dynamic>;
    return json
        .map((dynamic item) => ((item as Map<String, dynamic>)['availableDays'] as num?)?.toDouble() ?? 0)
        .toList();
  }
}
