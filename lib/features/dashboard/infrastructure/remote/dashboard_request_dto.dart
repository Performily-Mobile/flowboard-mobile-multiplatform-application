/// Pending request as returned by the Request backend; only what the dashboard shows is read.
class DashboardRequestDto {
  /// Creates the DTO.
  const DashboardRequestDto({
    required this.id,
    required this.requesterId,
    required this.requestTypeName,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.submittedAt,
  });

  /// Reads the DTO from its JSON.
  factory DashboardRequestDto.fromJson(Map<String, dynamic> json) {
    return DashboardRequestDto(
      id: (json['id'] as num).toInt(),
      requesterId: (json['requesterId'] as num).toInt(),
      requestTypeName: json['requestTypeName'] as String? ?? '',
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      submittedAt: json['submittedAt'] as String?,
    );
  }

  final int id;
  final int requesterId;
  final String requestTypeName;
  final String? startDate;
  final String? endDate;
  final String? startTime;
  final String? endTime;
  final String? submittedAt;
}
