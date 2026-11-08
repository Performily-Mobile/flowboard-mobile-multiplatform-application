import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/features/payroll/domain/entity/payslip_detail.dart';
import 'package:flowboard/features/payroll/domain/repository/payslip_repository.dart';

/// A published payslip of the employee using the app, with the employer data (MA-66).
class GetMyPayslipUseCase {
  /// Creates the use case.
  const GetMyPayslipUseCase({required this.repository, required this.currentEmployeeProvider});

  final PayslipRepository repository;
  final CurrentEmployeeProvider currentEmployeeProvider;

  /// The payslip [payslipId].
  Future<PayslipDetail> execute(int payslipId) =>
      repository.getMyPayslip(currentEmployeeProvider.currentEmployeeId(), payslipId);
}
