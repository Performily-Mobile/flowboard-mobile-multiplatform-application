/// Active area with its number of active employees (Workspace).
class DashboardArea {
  /// Creates the area.
  const DashboardArea({required this.id, required this.name, required this.activeEmployees});

  final int id;
  final String name;
  final int activeEmployees;
}

/// Count of attendance records of an area in a period (Attendance).
class AttendanceSummary {
  /// Creates the summary.
  const AttendanceSummary({
    required this.onTime,
    required this.late,
    required this.absent,
    required this.incomplete,
    required this.justified,
  });

  /// Records checked in on time.
  final int onTime;

  /// Records checked in late.
  final int late;

  /// Records marked as absent.
  final int absent;

  /// Records with a check-in but no check-out yet.
  final int incomplete;

  /// Records whose absence or lateness was justified.
  final int justified;

  /// Records with a check-in: on time, late or still without check-out.
  int get checkIns => onTime + late + incomplete;
}
