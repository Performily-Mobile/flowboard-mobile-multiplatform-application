import 'package:flowboard/features/payroll/domain/entity/payslip.dart';

/// Result of uploading a payslip: it was registered, or the employee already had one in the period.
sealed class PayslipUploadResult {
  const PayslipUploadResult();
}

/// The payslip was registered.
class PayslipUploaded extends PayslipUploadResult {
  /// Creates the result.
  const PayslipUploaded(this.payslip);

  final Payslip payslip;
}

/// The employee already had the [existing] payslip in the period; HR decides whether to replace it.
class PayslipDuplicate extends PayslipUploadResult {
  /// Creates the result.
  const PayslipDuplicate(this.existing);

  final Payslip existing;
}
