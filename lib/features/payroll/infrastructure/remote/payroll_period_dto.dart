/// Payroll period as returned by the API (PayrollPeriodResource).
class PayrollPeriodDto {
  /// Creates the DTO.
  const PayrollPeriodDto({
    required this.id,
    required this.year,
    required this.month,
    required this.label,
    required this.scheduledPaymentDate,
  });

  /// Reads the DTO from its JSON.
  factory PayrollPeriodDto.fromJson(Map<String, dynamic> json) {
    return PayrollPeriodDto(
      id: (json['id'] as num).toInt(),
      year: (json['year'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      label: json['label'] as String?,
      scheduledPaymentDate: json['scheduledPaymentDate'] as String,
    );
  }

  final int id;
  final int year;
  final int month;
  final String? label;
  final String scheduledPaymentDate;
}
