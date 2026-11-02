import 'package:flowboard/core/network/api_exception.dart';

/// Readable text of an error raised by a use case, a value object or the API.
///
/// Validation errors of the domain carry the Spanish message of the rule that failed; API errors
/// carry the message returned by the backend.
String workspaceErrorMessage(Object error, {String fallback = 'No se pudo completar la acción.'}) {
  if (error is ApiException) return error.message;
  if (error is ArgumentError) return error.message?.toString() ?? fallback;
  if (error is StateError) return error.message;
  if (error is FormatException) return error.message;
  return fallback;
}

/// Runs [block] and returns its result, or null when it fails.
///
/// Used for secondary data (filter options, catalogs) whose failure must not break the screen.
Future<T?> attemptOrNull<T>(Future<T> Function() block) async {
  try {
    return await block();
  } catch (_) {
    return null;
  }
}
