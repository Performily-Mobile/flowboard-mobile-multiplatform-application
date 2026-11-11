import 'package:flowboard/core/network/api_exception.dart';

/// Action that failed, used to choose the message of an error.
enum RequestAction { load, submit, cancel, resubmit, resolve, createType, changeTypeStatus, deleteType }

/// Readable text of an error raised by a use case, a value object or the API.
///
/// The backend answers in English, so the known business rules are translated; the rule may come
/// in the message or in the details of the error.
String requestErrorMessage(Object error, RequestAction action, String fallback) {
  if (error is ArgumentError) return error.message?.toString() ?? fallback;
  if (error is StateError) return error.message;
  if (error is! ApiException) return fallback;

  final String code = error.code ?? '';
  final String text = '${error.message} ${error.details ?? ''}'.toLowerCase();
  bool has(String part) => text.contains(part.toLowerCase());

  if (code.endsWith('CONFLICT')) {
    if (action == RequestAction.submit) return 'Ya tienes una solicitud para esos días.';
    if (action == RequestAction.createType) return 'Ya existe un tipo de solicitud con este nombre.';
    return error.message;
  }
  if (action == RequestAction.deleteType && (code == 'BUSINESS_RULE_VIOLATION' || has('has requests'))) {
    return 'Este tipo tiene solicitudes asociadas y no se puede eliminar.';
  }
  if (has('not ACTIVE') || has('is not active')) {
    return action == RequestAction.submit ? 'Este tipo de solicitud está inactivo.' : 'El colaborador no está activo.';
  }
  if (has('own request')) return 'No puedes aprobar tu propia solicitud.';
  if (has('assigned approver')) return 'Solo el aprobador asignado puede resolver esta solicitud.';
  if (has('Only IN_PROGRESS') || has('already')) return 'La solicitud ya fue atendida. Actualiza la lista.';
  if (has('Only UNDER_REVIEW')) return 'La solicitud ya no está en revisión.';
  if (has('attachment')) return 'Adjunta el documento de sustento.';
  if (has('required') && action == RequestAction.submit) return 'Completa los campos obligatorios.';
  if (has('whole days')) return 'Este tipo de solicitud necesita un periodo de días completos.';
  if (has('Not enough vacation days')) return 'El colaborador no tiene días suficientes.';
  if (code.endsWith('NOT_FOUND') && action == RequestAction.load) return 'No se encontró la solicitud.';
  return error.message.trim().isEmpty ? fallback : error.message;
}

/// Runs [block] and returns its result, or null when it fails.
///
/// Used for secondary data (catalogs, balances) whose failure must not break the screen.
Future<T?> attemptOrNull<T>(Future<T> Function() block) async {
  try {
    return await block();
  } catch (_) {
    return null;
  }
}
