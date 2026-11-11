import 'package:flowboard/core/network/api_exception.dart';

/// Action that failed, used to choose the message of an error.
enum IamAction { signIn, changePassword, signOut, loadAccounts, changeRole, resetPassword }

/// Readable text of an error raised by a use case or the API.
///
/// The backend answers in English and may send the reason with its HTTP status or inside the
/// details of the error, so both are checked.
String iamErrorMessage(Object error, IamAction action, String fallback) {
  if (error is ArgumentError) return error.message?.toString() ?? fallback;
  if (error is StateError) return error.message;
  if (error is! ApiException) return fallback;

  final int? status = error.statusCode;
  if (status == null) return error.message;
  final String text = '${error.message} ${error.details ?? ''}'.toLowerCase();
  bool has(String part) => text.contains(part.toLowerCase());

  switch (action) {
    case IamAction.signIn:
      if (status == 401 || has('invalid credentials')) return 'Usuario o contraseña incorrectos.';
      if (status == 403 || has('account disabled')) {
        return 'Tu cuenta está inhabilitada. Comunícate con Recursos Humanos.';
      }
      if (status == 400 || has('are required')) return 'Ingresa tu correo y tu contraseña.';
    case IamAction.changePassword:
      if (has('invalid credentials')) return 'La contraseña actual no es correcta.';
      if (has('must differ')) return 'La nueva contraseña debe ser distinta de la actual.';
      if (has('8+ characters')) {
        return 'Usa 8 caracteres, una mayúscula, una minúscula, un número y un símbolo.';
      }
    case IamAction.changeRole:
      if (has('at least one active hr')) return 'Debe quedar al menos una cuenta activa de RR. HH.';
      if (has('invalid role')) return 'El rol elegido no es válido.';
    case IamAction.resetPassword:
      if (has('account disabled')) return 'La cuenta está deshabilitada.';
    case IamAction.signOut:
    case IamAction.loadAccounts:
      break;
  }
  if (status == 401) return 'Tu sesión expiró. Vuelve a ingresar.';
  if (status == 403) return 'No tienes permiso para realizar esta acción.';
  return fallback;
}
