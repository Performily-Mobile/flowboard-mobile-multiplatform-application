/// Attendance counts of an area as returned by the backend.
///
/// Only the counters the dashboard needs are read; the other fields of the response are ignored.
class DashboardAttendanceSummaryDto {
  /// Creates the DTO.
  const DashboardAttendanceSummaryDto({
    required this.onTime,
    required this.late,
    required this.absent,
    required this.incomplete,
    required this.justified,
  });

  /// Reads the DTO from its JSON.
  factory DashboardAttendanceSummaryDto.fromJson(Map<String, dynamic> json) {
    int count(String key) => (json[key] as num?)?.toInt() ?? 0;
    return DashboardAttendanceSummaryDto(
      onTime: count('onTime'),
      late: count('late'),
      absent: count('absent'),
      incomplete: count('incomplete'),
      justified: count('justified'),
    );
  }

  final int onTime;
  final int late;
  final int absent;
  final int incomplete;
  final int justified;
}
