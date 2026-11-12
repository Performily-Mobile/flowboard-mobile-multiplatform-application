import 'package:flowboard/features/payroll/domain/entity/payslip.dart';
import 'package:flowboard/features/payroll/domain/repository/payslip_repository.dart';
import 'package:flowboard/features/payroll/domain/valueobject/payment_details.dart';

/// Registers an incident in the deposit of a published payslip, with its reason (MA-69, US45).
class MarkPayslipAsObservedUseCase {
  /// Creates the use case.
  const MarkPayslipAsObservedUseCase({required this.repository});

  final PayslipRepository repository;

  /// The updated payslip; throws [StateError] or [ArgumentError] when a rule fails.
  Future<Payslip> execute(Payslip payslip, String reason) async {
    if (!payslip.canUpdatePayment) {
      throw StateError('La boleta debe estar publicada para registrar su pago.');
    }
    final PaymentDetails details = PaymentDetails.observed(reason);
    return repository.markAsObserved(payslip.id, details.observationReason ?? '');
  }
}
