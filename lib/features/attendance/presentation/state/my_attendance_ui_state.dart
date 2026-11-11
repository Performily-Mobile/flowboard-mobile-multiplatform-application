import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_totals.dart';
import 'package:flowboard/features/attendance/domain/entity/my_attendance.dart';
import 'package:flowboard/features/attendance/domain/valueobject/attendance_period.dart';
import 'package:flowboard/features/attendance/domain/valueobject/punch_type.dart';
import 'package:flowboard/features/attendance/presentation/state/attendance_filters.dart';

const Object _keep = Object();

/// State of the attendance of the signed-in employee: today's punch and the records of a period.
class MyAttendanceUiState {
  /// Creates the state.
  const MyAttendanceUiState({
    required this.period,
    this.statusFilter = AttendanceStatusFilter.all,
    this.isLoading = false,
    this.attendance,
    this.errorMessage,
    this.isPunching = false,
    this.snackbarMessage,
  });

  final AttendancePeriod period;
  final AttendanceStatusFilter statusFilter;
  final bool isLoading;

  /// Last attendance received; null until the first load ends.
  final MyAttendance? attendance;
  final String? errorMessage;
  final bool isPunching;
  final String? snackbarMessage;

  /// Record of today; null when the employee has not punched yet.
  AttendanceRecord? get today => attendance?.today;

  /// Punch the employee can register now; null when the day is closed or the data is not loaded.
  PunchType? get nextPunch => attendance?.nextPunch;

  /// Records of the period that pass the status filter.
  List<AttendanceRecord> get records => statusFilter.apply(attendance?.records ?? const <AttendanceRecord>[]);

  /// Totals of the whole period, without the status filter.
  AttendanceTotals get totals => AttendanceTotals.of(attendance?.records ?? const <AttendanceRecord>[]);

  /// Copy with the given values replaced.
  MyAttendanceUiState copyWith({
    AttendancePeriod? period,
    AttendanceStatusFilter? statusFilter,
    bool? isLoading,
    Object? attendance = _keep,
    Object? errorMessage = _keep,
    bool? isPunching,
    Object? snackbarMessage = _keep,
  }) {
    return MyAttendanceUiState(
      period: period ?? this.period,
      statusFilter: statusFilter ?? this.statusFilter,
      isLoading: isLoading ?? this.isLoading,
      attendance: identical(attendance, _keep) ? this.attendance : attendance as MyAttendance?,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
      isPunching: isPunching ?? this.isPunching,
      snackbarMessage: identical(snackbarMessage, _keep) ? this.snackbarMessage : snackbarMessage as String?,
    );
  }
}
