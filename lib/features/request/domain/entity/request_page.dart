import 'package:flowboard/features/request/domain/entity/request.dart';

/// One page of requests, with the data needed to ask for the next one.
class RequestPage {
  /// Creates the page.
  const RequestPage({
    required this.items,
    required this.page,
    required this.size,
    required this.totalItems,
    required this.totalPages,
    required this.hasNext,
  });

  /// Default page size, the same as the backend.
  static const int defaultSize = 20;

  /// Requests of this page.
  final List<Request> items;

  /// Page number, starting at 0.
  final int page;

  final int size;

  /// Number of requests in every page.
  final int totalItems;

  final int totalPages;

  /// True when there is a page after this one.
  final bool hasNext;

  /// Copy with other [items].
  RequestPage withItems(List<Request> items) {
    return RequestPage(
      items: items,
      page: page,
      size: size,
      totalItems: totalItems,
      totalPages: totalPages,
      hasNext: hasNext,
    );
  }
}
