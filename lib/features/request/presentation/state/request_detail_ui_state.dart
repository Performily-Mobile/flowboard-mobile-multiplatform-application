import 'package:flowboard/core/domain/file_reference.dart';
import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/domain/entity/request_type.dart';

const Object _keep = Object();

/// State of the detail of one of the viewer's requests.
class RequestDetailUiState {
  /// Creates the state.
  const RequestDetailUiState({
    this.requestId,
    this.viewerId = 0,
    this.isLoading = false,
    this.request,
    this.type,
    this.errorMessage,
    this.isCancelDialogVisible = false,
    this.isCancelling = false,
    this.attachments = const <FileReference>[],
    this.isUploading = false,
    this.attachmentError,
    this.isResubmitting = false,
    this.snackbarMessage,
    this.resultMessage,
  });

  final int? requestId;
  final int viewerId;
  final bool isLoading;
  final Request? request;
  final RequestType? type;
  final String? errorMessage;
  final bool isCancelDialogVisible;
  final bool isCancelling;
  final List<FileReference> attachments;
  final bool isUploading;
  final String? attachmentError;
  final bool isResubmitting;
  final String? snackbarMessage;

  /// When set, the action finished and the screen closes with this message.
  final String? resultMessage;

  /// True when the viewer can still cancel the request.
  bool get canCancel {
    final Request? current = request;
    return current != null && !current.isResolved && current.requesterId == viewerId;
  }

  /// True when the request was returned to the viewer and can be sent again.
  bool get canResubmit {
    final Request? current = request;
    return current != null && current.isUnderReview && current.requesterId == viewerId;
  }

  /// Copy with the given values replaced.
  RequestDetailUiState copyWith({
    Object? requestId = _keep,
    bool? isLoading,
    Object? request = _keep,
    Object? type = _keep,
    Object? errorMessage = _keep,
    bool? isCancelDialogVisible,
    bool? isCancelling,
    List<FileReference>? attachments,
    bool? isUploading,
    Object? attachmentError = _keep,
    bool? isResubmitting,
    Object? snackbarMessage = _keep,
    Object? resultMessage = _keep,
  }) {
    return RequestDetailUiState(
      requestId: identical(requestId, _keep) ? this.requestId : requestId as int?,
      viewerId: viewerId,
      isLoading: isLoading ?? this.isLoading,
      request: identical(request, _keep) ? this.request : request as Request?,
      type: identical(type, _keep) ? this.type : type as RequestType?,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
      isCancelDialogVisible: isCancelDialogVisible ?? this.isCancelDialogVisible,
      isCancelling: isCancelling ?? this.isCancelling,
      attachments: attachments ?? this.attachments,
      isUploading: isUploading ?? this.isUploading,
      attachmentError: identical(attachmentError, _keep) ? this.attachmentError : attachmentError as String?,
      isResubmitting: isResubmitting ?? this.isResubmitting,
      snackbarMessage: identical(snackbarMessage, _keep) ? this.snackbarMessage : snackbarMessage as String?,
      resultMessage: identical(resultMessage, _keep) ? this.resultMessage : resultMessage as String?,
    );
  }
}
