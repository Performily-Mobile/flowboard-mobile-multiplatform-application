import 'package:flowboard/features/payroll/application/usecase/payslip_entry.dart';
import 'package:flowboard/features/payroll/domain/valueobject/payment_details.dart';
import 'package:flowboard/features/payroll/domain/valueobject/payment_status.dart';

const Object _keep = Object();

/// Values of the "Actualizar estado de pago" sheet (MA-69).
class PaymentSheetForm {
  /// Creates the form.
  const PaymentSheetForm({
    required this.entry,
    required this.subtitle,
    this.choice,
    this.paidOn,
    this.reason = '',
    this.isSaving = false,
    this.error,
  });

  final PayslipEntry entry;
  final String subtitle;

  /// [PaymentStatus.paid] or [PaymentStatus.observed]; null while HR has not chosen.
  final PaymentStatus? choice;
  final DateTime? paidOn;
  final String reason;
  final bool isSaving;
  final String? error;

  /// True when the chosen status has its date or reason.
  bool get canSave {
    if (isSaving) return false;
    return switch (choice) {
      PaymentStatus.paid => paidOn != null,
      PaymentStatus.observed =>
        reason.trim().isNotEmpty && reason.trim().length <= PaymentDetails.reasonMaxLength,
      _ => false,
    };
  }

  /// Copy with the given values replaced.
  PaymentSheetForm copyWith({
    Object? choice = _keep,
    DateTime? paidOn,
    String? reason,
    bool? isSaving,
    Object? error = _keep,
  }) {
    return PaymentSheetForm(
      entry: entry,
      subtitle: subtitle,
      choice: identical(choice, _keep) ? this.choice : choice as PaymentStatus?,
      paidOn: paidOn ?? this.paidOn,
      reason: reason ?? this.reason,
      isSaving: isSaving ?? this.isSaving,
      error: identical(error, _keep) ? this.error : error as String?,
    );
  }
}
