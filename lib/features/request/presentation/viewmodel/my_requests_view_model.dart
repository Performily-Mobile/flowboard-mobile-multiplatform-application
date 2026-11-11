import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/request/application/usecase/get_my_requests_use_case.dart';
import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/domain/entity/request_page.dart';
import 'package:flowboard/features/request/presentation/state/my_requests_ui_state.dart';
import 'package:flowboard/features/request/presentation/state/paging_state.dart';
import 'package:flowboard/features/request/presentation/state/requests_ui_state.dart';
import 'package:flowboard/features/request/presentation/viewmodel/request_error_messages.dart';

/// View model of the "Mis solicitudes" screen of the HR staff.
class MyRequestsViewModel extends ViewModel<MyRequestsUiState> {
  /// Creates the view model.
  MyRequestsViewModel({required this.getMyRequests}) : super(const MyRequestsUiState());

  final GetMyRequestsUseCase getMyRequests;

  /// Loads the first page of the requests with the selected filter.
  Future<void> load() async {
    final MyRequestsFilter filter = state.filter;
    update((MyRequestsUiState s) => s.copyWith(isLoading: s.requests.isEmpty, errorMessage: null));
    try {
      final RequestPage result = await getMyRequests.execute(status: filter.status);
      if (state.filter != filter) return;
      update((MyRequestsUiState s) =>
          s.copyWith(isLoading: false, requests: result.items, paging: PagingState.after(result)));
    } catch (error) {
      update((MyRequestsUiState s) => s.copyWith(
            isLoading: false,
            errorMessage: requestErrorMessage(error, RequestAction.load, 'No se pudieron cargar tus solicitudes.'),
          ));
    }
  }

  /// Shows the message left by another screen and reloads the list.
  void onResult(String message) {
    update((MyRequestsUiState s) => s.copyWith(snackbarMessage: message));
    load();
  }

  /// Clears the message once it was shown.
  void consumeMessage() => update((MyRequestsUiState s) => s.copyWith(snackbarMessage: null));

  /// Filters the requests by status.
  void onFilterSelected(MyRequestsFilter filter) {
    if (filter == state.filter) return;
    update((MyRequestsUiState s) =>
        s.copyWith(filter: filter, requests: const <Request>[], paging: const PagingState()));
    load();
  }

  /// Loads the next page and adds it at the end of the list.
  Future<void> loadMore() async {
    final MyRequestsUiState current = state;
    if (!current.paging.canLoadMore) return;
    final MyRequestsFilter filter = current.filter;
    update((MyRequestsUiState s) => s.copyWith(paging: s.paging.copyWith(isLoadingMore: true, loadMoreFailed: false)));
    try {
      final RequestPage result = await getMyRequests.execute(
        status: filter.status,
        page: PagingState.nextPage(current.requests.length),
      );
      if (state.filter != filter) return;
      update((MyRequestsUiState s) =>
          s.copyWith(requests: PagingState.merge(s.requests, result), paging: PagingState.after(result)));
    } catch (_) {
      if (state.filter != filter) return;
      update((MyRequestsUiState s) => s.copyWith(paging: s.paging.copyWith(isLoadingMore: false, loadMoreFailed: true)));
    }
  }
}
