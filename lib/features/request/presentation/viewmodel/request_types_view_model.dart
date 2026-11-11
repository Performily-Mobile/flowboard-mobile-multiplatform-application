import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/request/application/usecase/change_request_type_status_use_case.dart';
import 'package:flowboard/features/request/application/usecase/delete_request_type_use_case.dart';
import 'package:flowboard/features/request/application/usecase/get_request_types_use_case.dart';
import 'package:flowboard/features/request/domain/entity/request_type.dart';
import 'package:flowboard/features/request/presentation/state/request_types_ui_state.dart';
import 'package:flowboard/features/request/presentation/viewmodel/request_error_messages.dart';

/// View model of the catalog of request types: activate, deactivate and delete.
class RequestTypesViewModel extends ViewModel<RequestTypesUiState> {
  /// Creates the view model.
  RequestTypesViewModel({
    required this.getRequestTypes,
    required this.changeRequestTypeStatus,
    required this.deleteRequestType,
  }) : super(const RequestTypesUiState());

  final GetRequestTypesUseCase getRequestTypes;
  final ChangeRequestTypeStatusUseCase changeRequestTypeStatus;
  final DeleteRequestTypeUseCase deleteRequestType;

  /// Loads every request type.
  Future<void> load() async {
    update((RequestTypesUiState s) => s.copyWith(isLoading: s.types.isEmpty, errorMessage: null));
    try {
      final List<RequestType> types = await getRequestTypes.execute();
      update((RequestTypesUiState s) => s.copyWith(isLoading: false, types: types));
    } catch (error) {
      update((RequestTypesUiState s) => s.copyWith(
            isLoading: false,
            errorMessage: requestErrorMessage(error, RequestAction.load, 'No se pudieron cargar los tipos de solicitud.'),
          ));
    }
  }

  /// Shows the message of the new type and reloads the catalog.
  void onCreated(String message) {
    update((RequestTypesUiState s) => s.copyWith(snackbar: RequestTypesSnackbar(message: message)));
    load();
  }

  /// Activates or deactivates [type].
  Future<void> toggleStatus(RequestType type) async {
    if (state.isWorking) return;
    update((RequestTypesUiState s) => s.copyWith(isWorking: true));
    try {
      final RequestType updated = await changeRequestTypeStatus.execute(type);
      update((RequestTypesUiState s) => s.copyWith(
            isWorking: false,
            types: s.types.map((RequestType item) => item.id == updated.id ? updated : item).toList(),
            snackbar: RequestTypesSnackbar(
              message: updated.active ? '"${updated.name}" activado.' : '"${updated.name}" desactivado.',
            ),
          ));
    } catch (error) {
      update((RequestTypesUiState s) => s.copyWith(
            isWorking: false,
            snackbar: RequestTypesSnackbar(
              message: requestErrorMessage(error, RequestAction.changeTypeStatus, 'No se pudo cambiar el estado.'),
            ),
          ));
    }
  }

  /// Asks to confirm the deletion of [type].
  void requestDelete(RequestType type) => update((RequestTypesUiState s) => s.copyWith(typeToDelete: type));

  /// Closes the confirmation of the deletion.
  void dismissDelete() => update((RequestTypesUiState s) => s.copyWith(typeToDelete: null));

  /// Deletes the type; when it has requests, the message offers to deactivate it instead.
  Future<void> confirmDelete() async {
    final RequestType? type = state.typeToDelete;
    if (type == null || state.isWorking) return;
    update((RequestTypesUiState s) => s.copyWith(isWorking: true));
    try {
      await deleteRequestType.execute(type);
      update((RequestTypesUiState s) => s.copyWith(
            isWorking: false,
            typeToDelete: null,
            types: s.types.where((RequestType item) => item.id != type.id).toList(),
            snackbar: RequestTypesSnackbar(message: '"${type.name}" eliminado.'),
          ));
    } catch (error) {
      update((RequestTypesUiState s) => s.copyWith(
            isWorking: false,
            typeToDelete: null,
            snackbar: RequestTypesSnackbar(
              message: requestErrorMessage(error, RequestAction.deleteType, 'No se pudo eliminar el tipo.'),
              typeToDeactivate: type.active ? type : null,
            ),
          ));
    }
  }

  /// Clears the message once it was shown.
  void consumeMessage() => update((RequestTypesUiState s) => s.copyWith(snackbar: null));
}
