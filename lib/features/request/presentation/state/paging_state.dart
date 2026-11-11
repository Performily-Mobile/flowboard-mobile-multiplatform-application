import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/domain/entity/request_page.dart';

/// Paging of a request list: whether the server has more requests and whether the next ones are
/// loading.
class PagingState {
  /// Creates the state.
  const PagingState({this.hasMore = false, this.isLoadingMore = false, this.loadMoreFailed = false});

  /// Paging after [page] was received from the server.
  factory PagingState.after(RequestPage page) => PagingState(hasMore: page.hasNext);

  final bool hasMore;
  final bool isLoadingMore;
  final bool loadMoreFailed;

  /// True when the next page can be asked for.
  bool get canLoadMore => hasMore && !isLoadingMore;

  /// Copy with the given values replaced.
  PagingState copyWith({bool? hasMore, bool? isLoadingMore, bool? loadMoreFailed}) {
    return PagingState(
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    );
  }

  /// Page to ask for when the list already shows [loadedCount] requests.
  static int nextPage(int loadedCount) => loadedCount ~/ RequestPage.defaultSize;

  /// Requests of [page] added at the end of [current], skipping the ones already shown.
  static List<Request> merge(List<Request> current, RequestPage page) {
    final Set<int> shown = current.map((Request request) => request.id).toSet();
    return <Request>[
      ...current,
      ...page.items.where((Request request) => shown.add(request.id)),
    ];
  }
}
