import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/entity/employee_attendance.dart';
import 'package:flowboard/features/attendance/domain/valueobject/attendance_period.dart';
import 'package:flowboard/features/attendance/presentation/state/attendance_filters.dart';

const Object _keep = Object();

/// State of the attendance detail of one employee, seen by the HR staff.
class EmployeeAttendanceUiState {
  /// Creates the state.
  const EmployeeAttendanceUiState({
    this.employeeId,
    required this.period,
    this.statusFilter = AttendanceStatusFilter.all,
    this.isLoading = false,
    this.attendance,
    this.errorMessage,
  });

  /// Employee shown; null until the screen starts the detail.
  final int? employeeId;
  final AttendancePeriod period;
  final AttendanceStatusFilter statusFilter;
  final bool isLoading;

  /// Attendance of the period; null until it is loaded.
  final EmployeeAttendance? attendance;
  final String? errorMessage;

  /// Name to show in the header.
  String get title => attendance?.displayName ?? 'Colaborador';

  /// Records of the period that pass the status filter.
  List<AttendanceRecord> get records => statusFilter.apply(attendance?.records ?? const <AttendanceRecord>[]);

  /// Copy with the given values replaced.
  EmployeeAttendanceUiState copyWith({
    int? employeeId,
    AttendancePeriod? period,
    AttendanceStatusFilter? statusFilter,
    bool? isLoading,
    Object? attendance = _keep,
    Object? errorMessage = _keep,
  }) {
    return EmployeeAttendanceUiState(
      employeeId: employeeId ?? this.employeeId,
      period: period ?? this.period,
      statusFilter: statusFilter ?? this.statusFilter,
      isLoading: isLoading ?? this.isLoading,
      attendance: identical(attendance, _keep) ? this.attendance : attendance as EmployeeAttendance?,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
    );
  }
}
