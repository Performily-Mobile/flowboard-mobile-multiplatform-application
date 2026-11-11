import 'package:flowboard/core/network/api_exception.dart';

/// Readable text of an error raised by a use case, a value object or the API.
///
/// The backend may answer in English, so only the known rules are shown; any other error shows
/// [fallback].
String attendanceErrorMessage(Object error, String fallback) {
  if (error is ArgumentError) return error.message?.toString() ?? fallback;
  if (error is StateError) return error.message;
  if (error is! ApiException) return fallback;

  final String text = '${error.message} ${error.details ?? ''}'.toLowerCase();
  bool has(String part) => text.contains(part.toLowerCase());

  if (has('propia asistencia')) return 'Solo puedes registrar tu propia asistencia.';
  if (has('posterior al fin')) return 'La fecha de inicio no puede ser posterior a la de fin.';
  if (has('justification reason')) return 'Ingresa el motivo de la justificación.';
  if (error.statusCode == 403 || has('403') || has('forbidden')) {
    return 'No tienes permiso para ver esta información.';
  }
  if (error.statusCode == null && error.code == null) return 'No se pudo conectar con el servidor.';
  return fallback;
}
