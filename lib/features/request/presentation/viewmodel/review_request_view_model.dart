import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/request/application/usecase/approve_request_use_case.dart';
import 'package:flowboard/features/request/application/usecase/get_request_types_use_case.dart';
import 'package:flowboard/features/request/application/usecase/get_request_use_case.dart';
import 'package:flowboard/features/request/application/usecase/get_vacation_availability_use_case.dart';
import 'package:flowboard/features/request/application/usecase/reject_request_use_case.dart';
import 'package:flowboard/features/request/application/usecase/return_request_for_review_use_case.dart';
import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/domain/entity/request_type.dart';
import 'package:flowboard/features/request/domain/entity/vacation_availability.dart';
import 'package:flowboard/features/request/presentation/state/review_request_ui_state.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_formatters.dart';
import 'package:flowboard/features/request/presentation/viewmodel/request_error_messages.dart';

/// View model of the review of a request by its approver: approve, reject or return it.
class ReviewRequestViewModel extends ViewModel<ReviewRequestUiState> {
  /// Creates the view model.
  ReviewRequestViewModel({
    required CurrentEmployeeProvider currentEmployeeProvider,
    required this.getRequest,
    required this.getRequestTypes,
    required this.getVacationAvailability,
    required this.approveRequest,
    required this.rejectRequest,
    required this.returnRequestForReview,
  }) : super(ReviewRequestUiState(
          viewerId: currentEmployeeProvider.currentEmployeeId().value,
          role: currentEmployeeProvider.currentRole(),
        ));

  final GetRequestUseCase getRequest;
  final GetRequestTypesUseCase getRequestTypes;
  final GetVacationAvailabilityUseCase getVacationAvailability;
  final ApproveRequestUseCase approveRequest;
  final RejectRequestUseCase rejectRequest;
  final ReturnRequestForReviewUseCase returnRequestForReview;

  /// Loads the request, its type and, for a pending vacation request, the balance of the requester.
  Future<void> load(int requestId) async {
    update((ReviewRequestUiState s) => s.copyWith(requestId: requestId, isLoading: true, errorMessage: null));
    final Future<List<RequestType>?> types = attemptOrNull(() => getRequestTypes.execute());
    try {
      final Request request = await getRequest.execute(requestId);
      final RequestType? type = _typeOf(await types ?? const <RequestType>[], request.requestTypeId);
      update((ReviewRequestUiState s) => s.copyWith(isLoading: false, request: request, type: type));
      if (type != null && type.deductsVacationDays && request.isPending) {
        final VacationAvailability? availability =
            await attemptOrNull(() => getVacationAvailability.execute(employeeId: request.requesterId));
        if (availability != null) update((ReviewRequestUiState s) => s.copyWith(availability: availability));
      }
    } catch (error) {
      update((ReviewRequestUiState s) => s.copyWith(
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

  /// Approves the request.
  Future<void> approve() async {
    final Request? request = state.request;
    if (request == null || state.isProcessing) return;
    update((ReviewRequestUiState s) => s.copyWith(isProcessing: true));
    try {
      await approveRequest.execute(request);
      update((ReviewRequestUiState s) => s.copyWith(
            isProcessing: false,
            resultMessage: 'Solicitud de ${RequestFormatters.shortName(request.requesterName)} aprobada.',
          ));
    } catch (error) {
      update((ReviewRequestUiState s) => s.copyWith(
            isProcessing: false,
            snackbarMessage: requestErrorMessage(error, RequestAction.resolve, 'No se pudo aprobar la solicitud.'),
          ));
    }
  }

  /// Opens the dialog to reject the request.
  void showRejectDialog() {
    update((ReviewRequestUiState s) =>
        s.copyWith(activeAction: ReviewAction.reject, rejectReason: '', rejectError: null));
  }

  /// Opens the sheet to return the request for review.
  void showReturnSheet() {
    update((ReviewRequestUiState s) =>
        s.copyWith(activeAction: ReviewAction.returnForReview, returnComment: '', returnError: null));
  }

  /// Closes the open dialog or sheet.
  void dismissAction() => update((ReviewRequestUiState s) => s.copyWith(activeAction: ReviewAction.none));

  /// Changes the reason of the rejection.
  void onRejectReasonChange(String value) {
    update((ReviewRequestUiState s) => s.copyWith(rejectReason: value, rejectError: null));
  }

  /// Changes the comment for the requester.
  void onReturnCommentChange(String value) {
    update((ReviewRequestUiState s) => s.copyWith(returnComment: value, returnError: null));
  }

  /// Rejects the request with the reason of the dialog.
  Future<void> confirmReject() async {
    final ReviewRequestUiState current = state;
    final Request? request = current.request;
    if (request == null || current.isProcessing) return;
    if (current.rejectReason.trim().isEmpty) {
      update((ReviewRequestUiState s) => s.copyWith(rejectError: 'Ingresa el motivo para rechazar la solicitud.'));
      return;
    }
    update((ReviewRequestUiState s) => s.copyWith(isProcessing: true));
    try {
      await rejectRequest.execute(request, current.rejectReason);
      update((ReviewRequestUiState s) => s.copyWith(
            isProcessing: false,
            activeAction: ReviewAction.none,
            resultMessage: 'Solicitud de ${RequestFormatters.shortName(request.requesterName)} rechazada.',
          ));
    } catch (error) {
      update((ReviewRequestUiState s) => s.copyWith(
            isProcessing: false,
            rejectError: requestErrorMessage(error, RequestAction.resolve, 'No se pudo rechazar la solicitud.'),
          ));
    }
  }

  /// Returns the request to its requester with the comment of the sheet.
  Future<void> confirmReturn() async {
    final ReviewRequestUiState current = state;
    final Request? request = current.request;
    if (request == null || current.isProcessing) return;
    if (current.returnComment.trim().isEmpty) {
      update((ReviewRequestUiState s) => s.copyWith(returnError: 'Ingresa un comentario para el colaborador.'));
      return;
    }
    update((ReviewRequestUiState s) => s.copyWith(isProcessing: true));
    try {
      await returnRequestForReview.execute(request, current.returnComment);
      update((ReviewRequestUiState s) => s.copyWith(
            isProcessing: false,
            activeAction: ReviewAction.none,
            resultMessage:
                'Solicitud devuelta a ${RequestFormatters.shortName(request.requesterName)} para revisión.',
          ));
    } catch (error) {
      update((ReviewRequestUiState s) => s.copyWith(
            isProcessing: false,
            returnError: requestErrorMessage(error, RequestAction.resolve, 'No se pudo devolver la solicitud.'),
          ));
    }
  }

  /// Clears the message once it was shown.
  void consumeMessage() => update((ReviewRequestUiState s) => s.copyWith(snackbarMessage: null));

  RequestType? _typeOf(List<RequestType> types, int typeId) {
    for (final RequestType type in types) {
      if (type.id == typeId) return type;
    }
    return null;
  }
}
