import 'package:flowboard/features/payroll/domain/repository/payroll_period_repository.dart';

/// Publishes every payslip of the period that is still under review (MA-67, US43).
class PublishPeriodPayslipsUseCase {
  /// Creates the use case.
  const PublishPeriodPayslipsUseCase({required this.repository});

  final PayrollPeriodRepository repository;

  /// How many payslips were published.
  Future<int> execute(int payrollPeriodId) => repository.publishPayslips(payrollPeriodId);
}
