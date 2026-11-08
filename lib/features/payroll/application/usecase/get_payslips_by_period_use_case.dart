import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/features/payroll/application/usecase/payslip_entry.dart';
import 'package:flowboard/features/payroll/domain/entity/payroll_employee.dart';
import 'package:flowboard/features/payroll/domain/entity/payslip.dart';
import 'package:flowboard/features/payroll/domain/repository/payroll_employee_directory.dart';
import 'package:flowboard/features/payroll/domain/repository/payslip_repository.dart';

/// Payslips uploaded in a period (HR view, MA-67) with the name of their employee, sorted by last
/// name.
///
/// If Workspace does not answer, the list is still shown with the names sent by the backend.
class GetPayslipsByPeriodUseCase {
  /// Creates the use case.
  const GetPayslipsByPeriodUseCase({required this.repository, required this.directory});

  final PayslipRepository repository;
  final PayrollEmployeeDirectory directory;

  /// Entries of the period [payrollPeriodId].
  Future<List<PayslipEntry>> execute(int payrollPeriodId) async {
    final List<Payslip> payslips = await repository.getPayslipsByPeriod(payrollPeriodId);
    final Map<EmployeeId, PayrollEmployee> employees = await _employeesOrEmpty();
    return sortEntries(
      payslips.map((Payslip payslip) => PayslipEntry(payslip: payslip, employee: employees[payslip.employeeId])),
    );
  }

  Future<Map<EmployeeId, PayrollEmployee>> _employeesOrEmpty() async {
    try {
      final List<PayrollEmployee> employees = await directory.getEmployees();
      return <EmployeeId, PayrollEmployee>{for (final PayrollEmployee employee in employees) employee.id: employee};
    } catch (_) {
      return const <EmployeeId, PayrollEmployee>{};
    }
  }
}
