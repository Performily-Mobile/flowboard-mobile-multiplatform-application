import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/core/domain/file_reference.dart';
import 'package:flowboard/core/domain/money.dart';
import 'package:flowboard/features/payroll/domain/valueobject/pay_period.dart';
import 'package:flowboard/features/payroll/domain/valueobject/payment_details.dart';
import 'package:flowboard/features/payroll/domain/valueobject/payment_status.dart';
import 'package:flowboard/features/payroll/domain/valueobject/publication_status.dart';

/// Payslip of an employee in a payroll period: aggregate root of the Payroll bounded context.
///
/// Nothing is calculated: only the net amount issued by the payroll system is stored.
class Payslip {
  /// Creates the payslip.
  const Payslip({
    required this.id,
    required this.employeeId,
    required this.payrollPeriodId,
    required this.period,
    required this.file,
    required this.issueDate,
    required this.netAmount,
    required this.publicationStatus,
    required this.publishedAt,
    required this.payment,
    required this.employeeName,
  });

  final int id;
  final EmployeeId employeeId;
  final int payrollPeriodId;
  final PayPeriod period;
  final FileReference file;
  final DateTime issueDate;
  final Money netAmount;
  final PublicationStatus publicationStatus;
  final DateTime? publishedAt;
  final PaymentDetails payment;

  /// Name sent by the backend, used when Workspace does not answer.
  final String? employeeName;

  /// True when the employee can already see the payslip.
  bool get isPublished => publicationStatus == PublicationStatus.published;

  /// True while HR has not published it.
  bool get isUnderReview => publicationStatus == PublicationStatus.underReview;

  /// The payment status is only registered on published payslips.
  bool get canUpdatePayment => isPublished;

  /// A paid payslip can no longer be replaced.
  bool get canBeReplaced => payment.status != PaymentStatus.paid;

  @override
  bool operator ==(Object other) => other is Payslip && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
