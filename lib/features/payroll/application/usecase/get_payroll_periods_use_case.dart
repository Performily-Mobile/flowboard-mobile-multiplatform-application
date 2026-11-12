import 'package:flowboard/features/payroll/domain/entity/payroll_period.dart';
import 'package:flowboard/features/payroll/domain/repository/payroll_period_repository.dart';

/// Payroll periods, the most recent first.
class GetPayrollPeriodsUseCase {
  /// Creates the use case.
  const GetPayrollPeriodsUseCase({required this.repository});

  final PayrollPeriodRepository repository;

  /// Periods sorted from the most recent month.
  Future<List<PayrollPeriod>> execute() async {
    final List<PayrollPeriod> periods = await repository.getPayrollPeriods();
    return periods.toList()
      ..sort((PayrollPeriod a, PayrollPeriod b) {
        if (a.period == b.period) return 0;
        return a.period.isAfter(b.period) ? -1 : 1;
      });
  }
}
