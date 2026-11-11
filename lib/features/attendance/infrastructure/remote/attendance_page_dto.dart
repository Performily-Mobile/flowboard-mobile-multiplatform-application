import 'package:flowboard/features/attendance/infrastructure/remote/attendance_record_dto.dart';

/// Page of attendance records as returned by the API.
///
/// Spring may send the totals at the top level or inside a "page" object, so both are read.
class AttendancePageDto {
  /// Creates the DTO.
  const AttendancePageDto({required this.content, required this.totalElements, required this.last});

  /// Reads the DTO from its JSON.
  factory AttendancePageDto.fromJson(Map<String, dynamic> json) {
    final List<dynamic> content = json['content'] as List<dynamic>? ?? <dynamic>[];
    final Object? page = json['page'];
    final Map<String, dynamic> totals = page is Map<String, dynamic> ? page : json;
    final int totalElements = (totals['totalElements'] as num?)?.toInt() ?? content.length;
    final int number = (totals['number'] as num?)?.toInt() ?? 0;
    final int totalPages = (totals['totalPages'] as num?)?.toInt() ?? 1;
    return AttendancePageDto(
      content: content.map((dynamic item) => AttendanceRecordDto.fromJson(item as Map<String, dynamic>)).toList(),
      totalElements: totalElements,
      last: json['last'] as bool? ?? number + 1 >= totalPages,
    );
  }

  final List<AttendanceRecordDto> content;
  final int totalElements;
  final bool last;
}
