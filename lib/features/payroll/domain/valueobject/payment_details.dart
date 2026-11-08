import 'package:flowboard/features/payroll/domain/valueobject/payment_status.dart';

/// Deposit status of a payslip with its date or reason.
///
/// Rules: [PaymentStatus.pending] has no date or reason; [PaymentStatus.paid] has a date;
/// [PaymentStatus.observed] has a reason of up to [reasonMaxLength] characters. The deposit date
/// must not be in the future only when the payment is registered with [PaymentDetails.paid]; it is
/// not required when the status is rebuilt from server data.
class PaymentDetails {
  /// Creates the details; throws [ArgumentError] when they do not match the [status].
  PaymentDetails({required this.status, this.paidOn, this.observationReason}) {
    switch (status) {
      case PaymentStatus.pending:
        if (paidOn != null || observationReason != null) {
          throw ArgumentError('Un pago pendiente no tiene fecha ni motivo.');
        }
      case PaymentStatus.paid:
        if (paidOn == null) throw ArgumentError('Un pago realizado requiere fecha.');
      case PaymentStatus.observed:
        final String reason = observationReason?.trim() ?? '';
        if (reason.isEmpty || reason.length > reasonMaxLength) {
          throw ArgumentError('La observación requiere un motivo de hasta $reasonMaxLength caracteres.');
        }
    }
  }

  /// Pending deposit.
  factory PaymentDetails.pending() => PaymentDetails(status: PaymentStatus.pending);

  /// Deposit made on [paidOn]; throws [ArgumentError] when the date is in the future.
  factory PaymentDetails.paid(DateTime paidOn, {DateTime? today}) {
    final DateTime now = today ?? DateTime.now();
    if (paidOn.isAfter(DateTime(now.year, now.month, now.day))) {
      throw ArgumentError('La fecha de depósito no puede ser futura.');
    }
    return PaymentDetails(status: PaymentStatus.paid, paidOn: paidOn);
  }

  /// Deposit with an incident described by [reason].
  factory PaymentDetails.observed(String reason) =>
      PaymentDetails(status: PaymentStatus.observed, observationReason: reason.trim());

  /// Longest reason accepted for an observed deposit.
  static const int reasonMaxLength = 500;

  final PaymentStatus status;
  final DateTime? paidOn;
  final String? observationReason;
}
