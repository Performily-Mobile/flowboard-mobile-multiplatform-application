import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/request/application/usecase/get_resolved_team_requests_use_case.dart';
import 'package:flowboard/features/request/domain/entity/request_page.dart';
import 'package:flowboard/features/request/presentation/state/paging_state.dart';
import 'package:flowboard/features/request/presentation/state/resolved_requests_ui_state.dart';
import 'package:flowboard/features/request/presentation/viewmodel/request_error_messages.dart';

/// View model of the list of requests the viewer already approved or rejected.
class ResolvedRequestsViewModel extends ViewModel<ResolvedRequestsUiState> {
  /// Creates the view model.
  ResolvedRequestsViewModel({required this.getResolvedTeamRequests}) : super(const ResolvedRequestsUiState());

  final GetResolvedTeamRequestsUseCase getResolvedTeamRequests;

  /// Loads the first page of the resolved requests.
  Future<void> load() async {
    update((ResolvedRequestsUiState s) => s.copyWith(isLoading: s.requests.isEmpty, errorMessage: null));
    try {
      final RequestPage result = await getResolvedTeamRequests.execute();
      update((ResolvedRequestsUiState s) =>
          s.copyWith(isLoading: false, requests: result.items, paging: PagingState.after(result)));
    } catch (error) {
      update((ResolvedRequestsUiState s) => s.copyWith(
            isLoading: false,
            errorMessage:
                requestErrorMessage(error, RequestAction.load, 'No se pudieron cargar las solicitudes resueltas.'),
          ));
    }
  }

  /// Loads the next page and adds it at the end of the list.
  Future<void> loadMore() async {
    final ResolvedRequestsUiState current = state;
    if (!current.paging.canLoadMore) return;
    update((ResolvedRequestsUiState s) =>
        s.copyWith(paging: s.paging.copyWith(isLoadingMore: true, loadMoreFailed: false)));
    try {
      final RequestPage result =
          await getResolvedTeamRequests.execute(page: PagingState.nextPage(current.requests.length));
      update((ResolvedRequestsUiState s) =>
          s.copyWith(requests: PagingState.merge(s.requests, result), paging: PagingState.after(result)));
    } catch (_) {
      update((ResolvedRequestsUiState s) =>
          s.copyWith(paging: s.paging.copyWith(isLoadingMore: false, loadMoreFailed: true)));
    }
  }
}
