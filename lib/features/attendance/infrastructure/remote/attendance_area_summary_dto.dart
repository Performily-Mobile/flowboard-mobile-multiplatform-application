/// Totals of an area as returned by the API.
class AttendanceAreaSummaryDto {
  /// Creates the DTO.
  const AttendanceAreaSummaryDto({
    required this.areaId,
    required this.onTime,
    required this.late,
    required this.incomplete,
    required this.absent,
    required this.justified,
    required this.workedHours,
    required this.overtimeHours,
  });

  /// Reads the DTO from its JSON.
  factory AttendanceAreaSummaryDto.fromJson(Map<String, dynamic> json) {
    int count(String key) => (json[key] as num?)?.toInt() ?? 0;
    return AttendanceAreaSummaryDto(
      areaId: (json['areaId'] as num).toInt(),
      onTime: count('onTime'),
      late: count('late'),
      incomplete: count('incomplete'),
      absent: count('absent'),
      justified: count('justified'),
      workedHours: (json['workedHours'] as num?)?.toDouble() ?? 0,
      overtimeHours: (json['overtimeHours'] as num?)?.toDouble() ?? 0,
    );
  }

  final int areaId;
  final int onTime;
  final int late;
  final int incomplete;
  final int absent;
  final int justified;
  final double workedHours;
  final double overtimeHours;
}
