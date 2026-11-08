import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/features/payroll/domain/entity/payslip.dart';
import 'package:flowboard/features/payroll/domain/repository/payslip_repository.dart';

/// Published payslips of the employee using the app in a year, the most recent first (MA-65).
class GetMyPayslipsUseCase {
  /// Creates the use case.
  const GetMyPayslipsUseCase({required this.repository, required this.currentEmployeeProvider});

  final PayslipRepository repository;
  final CurrentEmployeeProvider currentEmployeeProvider;

  /// Payslips of [year].
  Future<List<Payslip>> execute(int year) async {
    final List<Payslip> payslips =
        await repository.getMyPayslips(currentEmployeeProvider.currentEmployeeId(), year);
    return payslips.toList()
      ..sort((Payslip a, Payslip b) {
        if (a.period == b.period) return 0;
        return a.period.isAfter(b.period) ? -1 : 1;
      });
  }
}
