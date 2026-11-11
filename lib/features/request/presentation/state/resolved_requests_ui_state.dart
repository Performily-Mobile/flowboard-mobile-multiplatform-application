import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/presentation/state/paging_state.dart';

const Object _keep = Object();

/// State of the list of requests the viewer already approved or rejected.
class ResolvedRequestsUiState {
  /// Creates the state.
  const ResolvedRequestsUiState({
    this.isLoading = false,
    this.requests = const <Request>[],
    this.paging = const PagingState(),
    this.errorMessage,
  });

  final bool isLoading;
  final List<Request> requests;
  final PagingState paging;
  final String? errorMessage;

  /// Copy with the given values replaced.
  ResolvedRequestsUiState copyWith({
    bool? isLoading,
    List<Request>? requests,
    PagingState? paging,
    Object? errorMessage = _keep,
  }) {
    return ResolvedRequestsUiState(
      isLoading: isLoading ?? this.isLoading,
      requests: requests ?? this.requests,
      paging: paging ?? this.paging,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
    );
  }
}
