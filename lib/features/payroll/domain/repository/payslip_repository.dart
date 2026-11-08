import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/core/domain/file_reference.dart';
import 'package:flowboard/core/domain/money.dart';
import 'package:flowboard/features/payroll/domain/entity/payslip.dart';
import 'package:flowboard/features/payroll/domain/entity/payslip_detail.dart';
import 'package:flowboard/features/payroll/domain/entity/payslip_download_link.dart';

/// Repository of the payslips.
abstract class PayslipRepository {
  /// Payslips uploaded in the payroll period [payrollPeriodId], in any status (HR view).
  Future<List<Payslip>> getPayslipsByPeriod(int payrollPeriodId);

  /// Registers the payslip of [employeeId] in the payroll period [payrollPeriodId].
  Future<Payslip> uploadPayslip(
    EmployeeId employeeId,
    int payrollPeriodId,
    FileReference file,
    DateTime issueDate,
    Money netAmount,
  );

  /// Replaces the file of the payslip [payslipId]; it goes back to under review.
  Future<Payslip> replaceFile(int payslipId, FileReference file, DateTime issueDate, Money netAmount);

  /// Registers the deposit of the payslip [payslipId] on [paidOn].
  Future<Payslip> markAsPaid(int payslipId, DateTime paidOn);

  /// Registers an incident in the deposit of the payslip [payslipId].
  Future<Payslip> markAsObserved(int payslipId, String reason);

  /// Published payslips of [employeeId] in [year] (employee view).
  Future<List<Payslip>> getMyPayslips(EmployeeId employeeId, int year);

  /// Published payslip [payslipId] of [employeeId] with the employer data (employee view).
  Future<PayslipDetail> getMyPayslip(EmployeeId employeeId, int payslipId);

  /// Temporary link to download the PDF of the payslip [payslipId] of [employeeId].
  Future<PayslipDownloadLink> getMyPayslipDownloadLink(EmployeeId employeeId, int payslipId);
}
