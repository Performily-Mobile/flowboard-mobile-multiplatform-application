import 'package:flowboard/core/domain/file_reference.dart';
import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/request/application/usecase/cancel_request_use_case.dart';
import 'package:flowboard/features/request/application/usecase/get_request_types_use_case.dart';
import 'package:flowboard/features/request/application/usecase/get_request_use_case.dart';
import 'package:flowboard/features/request/application/usecase/resubmit_request_use_case.dart';
import 'package:flowboard/features/request/application/usecase/store_attachment_use_case.dart';
import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/domain/entity/request_type.dart';
import 'package:flowboard/features/request/presentation/state/picked_attachment.dart';
import 'package:flowboard/features/request/presentation/state/request_detail_ui_state.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_formatters.dart';
import 'package:flowboard/features/request/presentation/viewmodel/request_error_messages.dart';

/// View model of the detail of one of the viewer's requests: cancel and resubmit.
class RequestDetailViewModel extends ViewModel<RequestDetailUiState> {
  /// Creates the view model.
  RequestDetailViewModel({
    required CurrentEmployeeProvider currentEmployeeProvider,
    required this.getRequest,
    required this.getRequestTypes,
    required this.cancelRequest,
    required this.resubmitRequest,
    required this.storeAttachment,
  }) : super(RequestDetailUiState(viewerId: currentEmployeeProvider.currentEmployeeId().value));

  final GetRequestUseCase getRequest;
  final GetRequestTypesUseCase getRequestTypes;
  final CancelRequestUseCase cancelRequest;
  final ResubmitRequestUseCase resubmitRequest;
  final StoreAttachmentUseCase storeAttachment;

  /// Loads the request and its type, used to label the fields and to know if it needs an attachment.
  Future<void> load(int requestId) async {
    update((RequestDetailUiState s) => s.copyWith(requestId: requestId, isLoading: true, errorMessage: null));
    final Future<List<RequestType>?> types = attemptOrNull(() => getRequestTypes.execute());
    try {
      final Request request = await getRequest.execute(requestId);
      final List<RequestType> allTypes = await types ?? const <RequestType>[];
      update((RequestDetailUiState s) => s.copyWith(
            isLoading: false,
            request: request,
            type: _typeOf(allTypes, request.requestTypeId),
            attachments: request.attachments,
          ));
    } catch (error) {
      update((RequestDetailUiState s) => s.copyWith(
            isLoading: false,
            errorMessage: requestErrorMessage(error, RequestAction.load, 'No se pudo cargar la solicitud.'),
          ));
    }
  }

  /// Loads the request again.
  void retry() {
    final int? requestId = state.requestId;
    if (requestId != null) load(requestId);
  }

  /// Opens the confirmation to cancel the request.
  void showCancelDialog() => update((RequestDetailUiState s) => s.copyWith(isCancelDialogVisible: true));

  /// Closes the confirmation to cancel the request.
  void dismissCancelDialog() => update((RequestDetailUiState s) => s.copyWith(isCancelDialogVisible: false));

  /// Cancels the request.
  Future<void> confirmCancel() async {
    final Request? request = state.request;
    if (request == null || state.isCancelling) return;
    update((RequestDetailUiState s) => s.copyWith(isCancelling: true));
    try {
      await cancelRequest.execute(request);
      update((RequestDetailUiState s) => s.copyWith(
            isCancelling: false,
            isCancelDialogVisible: false,
            resultMessage: 'Solicitud ${RequestFormatters.code(request.id)} cancelada.',
          ));
    } catch (error) {
      update((RequestDetailUiState s) => s.copyWith(
            isCancelling: false,
            isCancelDialogVisible: false,
            snackbarMessage: requestErrorMessage(error, RequestAction.cancel, 'No se pudo cancelar la solicitud.'),
          ));
    }
  }

  /// Stores the chosen file and adds it to the attachments of the resubmission.
  Future<void> onFilePicked(PickedAttachment file) async {
    update((RequestDetailUiState s) => s.copyWith(isUploading: true, attachmentError: null));
    try {
      final FileReference stored = await storeAttachment.execute(
        sourceUri: file.uri,
        fileName: file.name,
        contentType: file.contentType,
        sizeInBytes: file.sizeInBytes,
      );
      update((RequestDetailUiState s) =>
          s.copyWith(isUploading: false, attachments: <FileReference>[...s.attachments, stored]));
    } catch (error) {
      update((RequestDetailUiState s) => s.copyWith(
            isUploading: false,
            attachmentError: requestErrorMessage(error, RequestAction.resubmit, 'No se pudo adjuntar el archivo.'),
          ));
    }
  }

  /// Removes [file] from the attachments of the resubmission.
  void removeAttachment(FileReference file) {
    update((RequestDetailUiState s) =>
        s.copyWith(attachments: s.attachments.where((FileReference item) => !identical(item, file)).toList()));
  }

  /// Sends the request again to its approver.
  Future<void> resubmit() async {
    final RequestDetailUiState current = state;
    final Request? request = current.request;
    if (request == null || current.isResubmitting) return;
    update((RequestDetailUiState s) => s.copyWith(isResubmitting: true, attachmentError: null));
    try {
      await resubmitRequest.execute(request: request, type: current.type, attachments: current.attachments);
      update((RequestDetailUiState s) => s.copyWith(
            isResubmitting: false,
            resultMessage: 'Solicitud reenviada a ${RequestFormatters.shortName(request.approverName)}.',
          ));
    } catch (error) {
      update((RequestDetailUiState s) => s.copyWith(
            isResubmitting: false,
            snackbarMessage: requestErrorMessage(error, RequestAction.resubmit, 'No se pudo reenviar la solicitud.'),
          ));
    }
  }

  /// Clears the message once it was shown.
  void consumeMessage() => update((RequestDetailUiState s) => s.copyWith(snackbarMessage: null));

  RequestType? _typeOf(List<RequestType> types, int typeId) {
    for (final RequestType type in types) {
      if (type.id == typeId) return type;
    }
    return null;
  }
}
