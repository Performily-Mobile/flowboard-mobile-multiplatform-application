import 'package:flowboard/core/network/api_client.dart';
import 'package:flowboard/features/payroll/infrastructure/remote/payroll_period_dto.dart';

/// Endpoints of /payroll-periods.
class PayrollPeriodService {
  /// Creates the service.
  const PayrollPeriodService({required this.client});

  final ApiClient client;

  /// GET payroll-periods.
  Future<List<PayrollPeriodDto>> getPayrollPeriods() async {
    final List<dynamic> json = await client.get('payroll-periods') as List<dynamic>;
    return json.map((dynamic item) => PayrollPeriodDto.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// PATCH payroll-periods/{payrollPeriodId}/publish-payslips; returns how many were published.
  Future<int> publishPayslips(int payrollPeriodId) async {
    final Object? json = await client.patch('payroll-periods/$payrollPeriodId/publish-payslips');
    return ((json as Map<String, dynamic>)['publishedCount'] as num).toInt();
  }
}
