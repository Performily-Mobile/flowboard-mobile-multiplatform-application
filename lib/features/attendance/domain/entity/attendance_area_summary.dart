/// Totals of the attendance of an area in a period.
class AttendanceAreaSummary {
  /// Creates the summary.
  const AttendanceAreaSummary({
    required this.areaId,
    required this.onTime,
    required this.late,
    required this.incomplete,
    required this.absent,
    required this.justified,
    required this.workedHours,
    required this.overtimeHours,
  });

  final int areaId;
  final int onTime;
  final int late;
  final int incomplete;
  final int absent;
  final int justified;
  final double workedHours;
  final double overtimeHours;

  /// Work days counted.
  int get total => onTime + late + incomplete + absent + justified;

  /// Share of punctual days, from 0 to 100; 0 when there are no days.
  int get punctualityPercentage => total == 0 ? 0 : (onTime * 100 / total).round();
}
