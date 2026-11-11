import 'package:flowboard/core/session/user_role.dart';
import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/domain/entity/request_type.dart';
import 'package:flowboard/features/request/domain/entity/vacation_availability.dart';
import 'package:flowboard/features/request/domain/valueobject/approver_type.dart';

const Object _keep = Object();

/// Dialog or sheet open in the review screen.
enum ReviewAction { none, reject, returnForReview }

/// State of the review of a request by its approver.
class ReviewRequestUiState {
  /// Creates the state.
  const ReviewRequestUiState({
    this.requestId,
    this.viewerId = 0,
    this.role = UserRole.employee,
    this.isLoading = false,
    this.request,
    this.type,
    this.availability,
    this.errorMessage,
    this.activeAction = ReviewAction.none,
    this.rejectReason = '',
    this.rejectError,
    this.returnComment = '',
    this.returnError,
    this.isProcessing = false,
    this.snackbarMessage,
    this.resultMessage,
  });

  final int? requestId;
  final int viewerId;
  final UserRole role;
  final bool isLoading;
  final Request? request;
  final RequestType? type;
  final VacationAvailability? availability;
  final String? errorMessage;
  final ReviewAction activeAction;
  final String rejectReason;
  final String? rejectError;
  final String returnComment;
  final String? returnError;
  final bool isProcessing;
  final String? snackbarMessage;

  /// When set, the request was resolved and the screen closes with this message.
  final String? resultMessage;

  /// True when the viewer is the approver of a pending request that is not their own.
  bool get canResolve {
    final Request? current = request;
    if (current == null || !current.isPending) return false;
    if (current.requesterId == viewerId) return false;
    return switch (current.approverType) {
      ApproverType.hrStaff => role == UserRole.humanResources,
      ApproverType.directManager => current.approverEmployeeId == viewerId,
    };
  }

  /// Copy with the given values replaced.
  ReviewRequestUiState copyWith({
    Object? requestId = _keep,
    bool? isLoading,
    Object? request = _keep,
    Object? type = _keep,
    Object? availability = _keep,
    Object? errorMessage = _keep,
    ReviewAction? activeAction,
    String? rejectReason,
    Object? rejectError = _keep,
    String? returnComment,
    Object? returnError = _keep,
    bool? isProcessing,
    Object? snackbarMessage = _keep,
    Object? resultMessage = _keep,
  }) {
    return ReviewRequestUiState(
      requestId: identical(requestId, _keep) ? this.requestId : requestId as int?,
      viewerId: viewerId,
      role: role,
      isLoading: isLoading ?? this.isLoading,
      request: identical(request, _keep) ? this.request : request as Request?,
      type: identical(type, _keep) ? this.type : type as RequestType?,
      availability: identical(availability, _keep) ? this.availability : availability as VacationAvailability?,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
      activeAction: activeAction ?? this.activeAction,
      rejectReason: rejectReason ?? this.rejectReason,
      rejectError: identical(rejectError, _keep) ? this.rejectError : rejectError as String?,
      returnComment: returnComment ?? this.returnComment,
      returnError: identical(returnError, _keep) ? this.returnError : returnError as String?,
      isProcessing: isProcessing ?? this.isProcessing,
      snackbarMessage: identical(snackbarMessage, _keep) ? this.snackbarMessage : snackbarMessage as String?,
      resultMessage: identical(resultMessage, _keep) ? this.resultMessage : resultMessage as String?,
    );
  }
}
