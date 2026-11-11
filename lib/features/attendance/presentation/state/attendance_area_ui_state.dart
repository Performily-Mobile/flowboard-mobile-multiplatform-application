import 'package:flowboard/features/attendance/domain/entity/area_attendance_report.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_area.dart';
import 'package:flowboard/features/attendance/domain/valueobject/attendance_period.dart';

const Object _keep = Object();

/// State of the area report: the totals of an area and its employees.
class AttendanceAreaUiState {
  /// Creates the state.
  const AttendanceAreaUiState({
    required this.period,
    this.areas = const <AttendanceArea>[],
    this.selectedArea,
    this.isLoadingAreas = false,
    this.isLoading = false,
    this.report,
    this.errorMessage,
  });

  final AttendancePeriod period;
  final List<AttendanceArea> areas;
  final AttendanceArea? selectedArea;
  final bool isLoadingAreas;
  final bool isLoading;

  /// Report of the selected area; null until it is loaded.
  final AreaAttendanceReport? report;
  final String? errorMessage;

  /// Copy with the given values replaced.
  AttendanceAreaUiState copyWith({
    AttendancePeriod? period,
    List<AttendanceArea>? areas,
    Object? selectedArea = _keep,
    bool? isLoadingAreas,
    bool? isLoading,
    Object? report = _keep,
    Object? errorMessage = _keep,
  }) {
    return AttendanceAreaUiState(
      period: period ?? this.period,
      areas: areas ?? this.areas,
      selectedArea: identical(selectedArea, _keep) ? this.selectedArea : selectedArea as AttendanceArea?,
      isLoadingAreas: isLoadingAreas ?? this.isLoadingAreas,
      isLoading: isLoading ?? this.isLoading,
      report: identical(report, _keep) ? this.report : report as AreaAttendanceReport?,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
    );
  }
}
