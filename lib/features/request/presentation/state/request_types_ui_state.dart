import 'package:flowboard/features/request/domain/entity/request_type.dart';

const Object _keep = Object();

/// Message of the catalog, with the type to deactivate when it could not be deleted.
class RequestTypesSnackbar {
  /// Creates the message.
  const RequestTypesSnackbar({required this.message, this.typeToDeactivate});

  final String message;
  final RequestType? typeToDeactivate;
}

/// State of the catalog of request types.
class RequestTypesUiState {
  /// Creates the state.
  const RequestTypesUiState({
    this.isLoading = false,
    this.types = const <RequestType>[],
    this.errorMessage,
    this.typeToDelete,
    this.isWorking = false,
    this.snackbar,
  });

  final bool isLoading;
  final List<RequestType> types;
  final String? errorMessage;
  final RequestType? typeToDelete;
  final bool isWorking;
  final RequestTypesSnackbar? snackbar;

  /// Copy with the given values replaced.
  RequestTypesUiState copyWith({
    bool? isLoading,
    List<RequestType>? types,
    Object? errorMessage = _keep,
    Object? typeToDelete = _keep,
    bool? isWorking,
    Object? snackbar = _keep,
  }) {
    return RequestTypesUiState(
      isLoading: isLoading ?? this.isLoading,
      types: types ?? this.types,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
      typeToDelete: identical(typeToDelete, _keep) ? this.typeToDelete : typeToDelete as RequestType?,
      isWorking: isWorking ?? this.isWorking,
      snackbar: identical(snackbar, _keep) ? this.snackbar : snackbar as RequestTypesSnackbar?,
    );
  }
}
