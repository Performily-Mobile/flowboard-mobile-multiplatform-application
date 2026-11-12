import 'package:flowboard/features/payroll/domain/entity/payroll_period.dart';

/// Repository of the payroll periods.
abstract class PayrollPeriodRepository {
  /// Payroll periods registered by HR.
  Future<List<PayrollPeriod>> getPayrollPeriods();

  /// Publishes every payslip of the period still under review; returns how many were published.
  Future<int> publishPayslips(int payrollPeriodId);
}
