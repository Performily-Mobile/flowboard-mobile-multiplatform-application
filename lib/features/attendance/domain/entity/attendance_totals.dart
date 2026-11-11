import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/valueobject/attendance_status.dart';

/// Counts and hours of a list of attendance records.
class AttendanceTotals {
  /// Creates the totals.
  const AttendanceTotals({
    required this.onTime,
    required this.late,
    required this.incomplete,
    required this.absent,
    required this.justified,
    required this.workedHours,
    required this.overtimeHours,
  });

  /// Totals of [records].
  factory AttendanceTotals.of(List<AttendanceRecord> records) {
    int count(AttendanceStatus status) => records.where((AttendanceRecord r) => r.status == status).length;
    double worked = 0;
    double overtime = 0;
    for (final AttendanceRecord record in records) {
      worked += record.workedHours;
      overtime += record.overtimeHours;
    }
    return AttendanceTotals(
      onTime: count(AttendanceStatus.onTime),
      late: count(AttendanceStatus.late),
      incomplete: count(AttendanceStatus.incomplete),
      absent: count(AttendanceStatus.absent),
      justified: count(AttendanceStatus.justified),
      workedHours: worked,
      overtimeHours: overtime,
    );
  }

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
