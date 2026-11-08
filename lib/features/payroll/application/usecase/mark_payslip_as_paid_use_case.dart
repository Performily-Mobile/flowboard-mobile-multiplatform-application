import 'package:flowboard/features/payroll/domain/entity/payslip.dart';
import 'package:flowboard/features/payroll/domain/repository/payslip_repository.dart';
import 'package:flowboard/features/payroll/domain/valueobject/payment_details.dart';

/// Registers the deposit of a published payslip (MA-69, US45).
class MarkPayslipAsPaidUseCase {
  /// Creates the use case.
  const MarkPayslipAsPaidUseCase({required this.repository});

  final PayslipRepository repository;

  /// The updated payslip; throws [StateError] or [ArgumentError] when a rule fails.
  Future<Payslip> execute(Payslip payslip, DateTime paidOn) async {
    if (!payslip.canUpdatePayment) {
      throw StateError('La boleta debe estar publicada para registrar su pago.');
    }
    PaymentDetails.paid(paidOn);
    return repository.markAsPaid(payslip.id, paidOn);
  }
}
