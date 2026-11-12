import 'package:flowboard/features/payroll/domain/entity/payroll_period.dart';
import 'package:flowboard/features/payroll/domain/repository/payroll_period_repository.dart';
import 'package:flowboard/features/payroll/infrastructure/mapper/payroll_mapper.dart';
import 'package:flowboard/features/payroll/infrastructure/remote/payroll_period_dto.dart';
import 'package:flowboard/features/payroll/infrastructure/remote/payroll_period_service.dart';

/// Payroll periods read from the Flowboard API.
class PayrollPeriodRepositoryImpl implements PayrollPeriodRepository {
  /// Creates the repository.
  const PayrollPeriodRepositoryImpl({required this.service});

  final PayrollPeriodService service;

  @override
  Future<List<PayrollPeriod>> getPayrollPeriods() async {
    final List<PayrollPeriodDto> dtos = await service.getPayrollPeriods();
    return dtos.map(PayrollMapper.toPayrollPeriod).toList();
  }

  @override
  Future<int> publishPayslips(int payrollPeriodId) => service.publishPayslips(payrollPeriodId);
}
