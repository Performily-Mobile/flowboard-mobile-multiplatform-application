class AttendanceAreaReport {
  final int areaId;
  final int total, late, absent;

  const AttendanceAreaReport({
    required this.areaId,
    required this.total,
    required this.late,
    required this.absent,
  });
}