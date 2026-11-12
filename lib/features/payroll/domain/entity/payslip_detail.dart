import 'package:flowboard/features/payroll/domain/entity/payslip.dart';

/// Published payslip of the employee with the data of the employer (MA-66).
class PayslipDetail {
  /// Creates the detail.
  const PayslipDetail({required this.payslip, required this.companyLegalName, required this.companyTaxId});

  final Payslip payslip;

  /// Legal name of the employer, for example "EMPRESA S.A.C.".
  final String? companyLegalName;

  /// Tax id (RUC) of the employer.
  final String? companyTaxId;
}
