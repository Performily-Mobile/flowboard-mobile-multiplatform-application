import 'package:flowboard/features/payroll/domain/valueobject/pay_period.dart';

/// Payroll month with its scheduled payment date. There is one payroll period per [PayPeriod].
class PayrollPeriod {
  /// Creates the payroll period.
  const PayrollPeriod({required this.id, required this.period, required this.scheduledPaymentDate});

  final int id;
  final PayPeriod period;
  final DateTime scheduledPaymentDate;

  @override
  bool operator ==(Object other) => other is PayrollPeriod && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
