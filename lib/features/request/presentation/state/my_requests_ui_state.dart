import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/presentation/state/paging_state.dart';
import 'package:flowboard/features/request/presentation/state/requests_ui_state.dart';

const Object _keep = Object();

/// State of the "Mis solicitudes" screen that HR staff open from "Más".
class MyRequestsUiState {
  /// Creates the state.
  const MyRequestsUiState({
    this.isLoading = false,
    this.requests = const <Request>[],
    this.errorMessage,
    this.filter = MyRequestsFilter.all,
    this.paging = const PagingState(),
    this.snackbarMessage,
  });

  final bool isLoading;
  final List<Request> requests;
  final String? errorMessage;
  final MyRequestsFilter filter;
  final PagingState paging;
  final String? snackbarMessage;

  /// Copy with the given values replaced.
  MyRequestsUiState copyWith({
    bool? isLoading,
    List<Request>? requests,
    Object? errorMessage = _keep,
    MyRequestsFilter? filter,
    PagingState? paging,
    Object? snackbarMessage = _keep,
  }) {
    return MyRequestsUiState(
      isLoading: isLoading ?? this.isLoading,
      requests: requests ?? this.requests,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
      filter: filter ?? this.filter,
      paging: paging ?? this.paging,
      snackbarMessage: identical(snackbarMessage, _keep) ? this.snackbarMessage : snackbarMessage as String?,
    );
  }
}
