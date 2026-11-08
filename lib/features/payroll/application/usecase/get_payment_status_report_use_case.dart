import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/features/payroll/application/usecase/payslip_entry.dart';
import 'package:flowboard/features/payroll/domain/entity/payroll_employee.dart';
import 'package:flowboard/features/payroll/domain/entity/payslip.dart';
import 'package:flowboard/features/payroll/domain/repository/payroll_employee_directory.dart';
import 'package:flowboard/features/payroll/domain/repository/payslip_repository.dart';
import 'package:flowboard/features/payroll/domain/valueobject/payment_status.dart';

/// Published payslips of a period filtered by area and deposit status (MA-69), sorted by last name.
///
/// Only published payslips have a deposit status. If Workspace does not answer, the list is still
/// shown with the names sent by the backend, but it cannot be filtered by area.
class GetPaymentStatusReportUseCase {
  /// Creates the use case.
  const GetPaymentStatusReportUseCase({required this.repository, required this.directory});

  final PayslipRepository repository;
  final PayrollEmployeeDirectory directory;

  /// Entries of the period [payrollPeriodId] in the area [areaId] with the deposit [status];
  /// a null filter keeps every payslip.
  Future<List<PayslipEntry>> execute(int payrollPeriodId, {int? areaId, PaymentStatus? status}) async {
    final List<Payslip> payslips = await repository.getPayslipsByPeriod(payrollPeriodId);
    final Map<EmployeeId, PayrollEmployee> employees = await _employeesOrEmpty();
    final Iterable<PayslipEntry> entries = payslips
        .where((Payslip payslip) => payslip.isPublished)
        .where((Payslip payslip) => status == null || payslip.payment.status == status)
        .map((Payslip payslip) => PayslipEntry(payslip: payslip, employee: employees[payslip.employeeId]))
        .where((PayslipEntry entry) => areaId == null || entry.employee?.areaId == areaId);
    return sortEntries(entries);
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
