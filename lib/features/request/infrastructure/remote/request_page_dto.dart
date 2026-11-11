import 'package:flowboard/features/request/infrastructure/remote/request_dto.dart';

/// Page of requests returned by the list endpoints.
class RequestPageDto {
  /// Creates the DTO.
  const RequestPageDto({
    required this.items,
    required this.page,
    required this.size,
    required this.totalItems,
    required this.totalPages,
    required this.hasNext,
  });

  /// Reads the DTO from its JSON.
  factory RequestPageDto.fromJson(Map<String, dynamic> json) {
    final Object? items = json['items'];
    return RequestPageDto(
      items: items is List<dynamic>
          ? items.map((dynamic item) => RequestDto.fromJson(item as Map<String, dynamic>)).toList()
          : <RequestDto>[],
      page: (json['page'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 0,
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      hasNext: json['hasNext'] as bool? ?? false,
    );
  }

  final List<RequestDto> items;
  final int page;
  final int size;
  final int totalItems;
  final int totalPages;
  final bool hasNext;
}
