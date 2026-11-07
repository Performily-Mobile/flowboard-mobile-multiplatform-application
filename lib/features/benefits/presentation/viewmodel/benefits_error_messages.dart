import 'package:flowboard/core/network/api_exception.dart';

/// Action being performed when a failure happened; it picks the right text for the user.
enum BenefitsAction { load, createType, changeTypeStatus, assignToEmployee, assignToArea, deliver, adjust }

/// Translates a failure of Benefits into the Spanish texts of the prototype.
///
/// The backend answers with a generic `message` ("Business rule violation"), the concrete reason in
/// English in `details` and a code such as BENEFITTYPE_CONFLICT or BUSINESS_RULE_VIOLATION. Errors
/// are recognized by the code and by the text of `details` + `message`. "no active employees" is
/// checked before "ACTIVE employees" because the former also contains the latter. Generic codes fall
/// back to the action text; validation errors of the domain already carry their Spanish message.
String benefitsMessage(Object error, BenefitsAction action, String fallback) {
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

  if (code.endsWith('CONFLICT')) {
    return switch (action) {
      BenefitsAction.createType => 'Ya existe un beneficio con este nombre.',
      BenefitsAction.assignToEmployee => 'El colaborador ya tiene este beneficio en un periodo que se cruza.',
      BenefitsAction.assignToArea => 'Todos los colaboradores activos del área ya tienen este beneficio en el periodo.',
      _ => fallback,
    };
  }

  final String? known = switch (true) {
    _ when has('is not active') => 'Este beneficio está inactivo y no se puede asignar.',
    _ when has('no active employees') || has('no employees to receive') => 'El área no tiene colaboradores activos.',
    _ when has('only be assigned to ACTIVE employees') || has('ACTIVE employees') =>
      'Solo se puede asignar a colaboradores activos.',
    _ when has('already delivered') => 'La entrega de este beneficio ya fue registrada.',
    _ when has('cancelled assignment') => 'Esta asignación fue anulada y no se puede entregar.',
    _ when has('before the validity starts') => 'La fecha de entrega no puede ser anterior al inicio de la vigencia.',
    _ when has('cannot be in the future') => 'La fecha no puede ser futura.',
    _ when has('leave the balance negative') || has('Not enough vacation days') =>
      'No puede descontar más de los días disponibles.',
    _ when has('not valid for a benefit') => 'Las unidades deben ser un número entero.',
    _ when has('at most 2 decimals') => 'Usa como máximo 2 decimales.',
    _ when has('must be greater than 0') || has('cannot be zero') => 'La cantidad debe ser mayor que cero.',
    _ when has('End date cannot be before') => 'La fecha final no puede ser anterior a la inicial.',
    _ when has('reason is required') => 'Ingresa el motivo del ajuste.',
    _ when has('reason cannot exceed') => 'El motivo admite hasta 250 caracteres.',
    _ when has('name is required') => 'Ingresa el nombre del beneficio.',
    _ when has('name cannot exceed') => 'El nombre admite hasta 80 caracteres.',
    _ => null,
  };
  if (known != null) return known;

  if (code.endsWith('NOT_FOUND')) {
    return action == BenefitsAction.load
        ? 'No se encontró la información solicitada.'
        : 'No se encontró el registro solicitado.';
  }
  if (code == 'VALIDATION_ERROR' || code == 'BUSINESS_RULE_VIOLATION' || code == 'UNEXPECTED_ERROR') return fallback;
  return error.message.trim().isEmpty ? fallback : error.message;
}
