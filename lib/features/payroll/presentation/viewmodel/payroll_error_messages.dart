import 'package:flowboard/core/network/api_exception.dart';

/// Action being performed when a failure happened; it picks the right text for the user.
enum PayrollAction { load, upload, replace, publish, registerPayment, download }

/// Translates a failure of Payroll into a Spanish text for the user.
///
/// The backend answers with a generic `message`, the concrete reason in English in `details` and a
/// code such as PAYSLIP_CONFLICT or BUSINESS_RULE_VIOLATION. Errors are recognized by the code and by
/// the text of `details` + `message`. Validation errors of the domain already carry their Spanish
/// message.
String payrollMessage(Object error, PayrollAction action, String fallback) {
  if (error is! ApiException) {
    final String? message = switch (error) {
      ArgumentError(:final Object? message) => message?.toString(),
      StateError(:final String message) => message,
      FormatException(:final String message) => message,
      _ => null,
    };
    return message == null || message.trim().isEmpty ? fallback : message;
  }
  final String code = error.code ?? '';
  final String text = <String?>[error.details, error.message].whereType<String>().join(' ').toLowerCase();
  bool has(String fragment) => text.contains(fragment.toLowerCase());

  if (code == 'PAYSLIP_CONFLICT' || has('already has a payslip')) {
    return 'El colaborador ya tiene una boleta en este período.';
  }

  final String? known = switch (true) {
    _ when has('paid payslip cannot be replaced') => 'La boleta ya está pagada y no se puede reemplazar.',
    _ when has('already published') => 'La boleta ya fue publicada.',
    _ when has('must be published first') => 'La boleta debe estar publicada para registrar su pago.',
    _ when has('must be a pdf') => 'Sube archivos PDF.',
    _ when has('cannot exceed 5 mb') => 'El archivo supera los 5 MB.',
    _ when has('payment date cannot be in the future') => 'La fecha de depósito no puede ser futura.',
    _ when has('payment date is required') || has('paidon is required') => 'Ingresa la fecha de depósito.',
    _ when has('observation reason is required') || has('reason is required') => 'Ingresa el motivo de la observación.',
    _ when has('cannot be a future month') => 'El período no puede ser futuro.',
    _ => null,
  };
  if (known != null) return known;

  if (code == 'EMPLOYEE_NOT_FOUND') return 'No existe un colaborador con el identificador del archivo.';
  if (code.endsWith('NOT_FOUND')) {
    return action == PayrollAction.load
        ? 'No se encontró la información solicitada.'
        : 'No se encontró la boleta solicitada.';
  }
  if (code == 'VALIDATION_ERROR' || code == 'BUSINESS_RULE_VIOLATION' || code == 'UNEXPECTED_ERROR') return fallback;
  return error.message.trim().isEmpty ? fallback : error.message;
}
