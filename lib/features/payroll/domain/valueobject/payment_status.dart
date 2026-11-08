/// Deposit status of a payslip.
enum PaymentStatus {
  pending('Pendiente'),
  paid('Pagado'),
  observed('Observado');

  const PaymentStatus(this.label);

  /// Text shown in the status chip.
  final String label;
}
