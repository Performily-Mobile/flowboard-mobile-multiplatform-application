import 'package:flowboard/features/attendance/domain/entity/attendance_area.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_employee_hours.dart';
import 'package:flowboard/features/attendance/domain/valueobject/attendance_period.dart';
import 'package:flowboard/features/attendance/presentation/state/attendance_filters.dart';

const Object _keep = Object();

/// State of the hours report: worked and overtime hours of the employees of an area.
class AttendanceHoursUiState {
  /// Creates the state.
  const AttendanceHoursUiState({
    required this.period,
    this.areas = const <AttendanceArea>[],
    this.selectedArea,
    this.isLoadingAreas = false,
    this.isLoading = false,
    this.rows = const <AttendanceEmployeeHours>[],
    this.order = AttendanceHoursOrder.overtime,
    this.errorMessage,
  });

  final AttendancePeriod period;
  final List<AttendanceArea> areas;
  final AttendanceArea? selectedArea;
  final bool isLoadingAreas;
  final bool isLoading;

  /// Rows of the report, as received.
  final List<AttendanceEmployeeHours> rows;
  final AttendanceHoursOrder order;
  final String? errorMessage;

  /// Rows sorted by [order].
  List<AttendanceEmployeeHours> get sortedRows {
    int byName(AttendanceEmployeeHours a, AttendanceEmployeeHours b) =>
        a.employee.name.toLowerCase().compareTo(b.employee.name.toLowerCase());
    final List<AttendanceEmployeeHours> sorted = rows.toList();
    switch (order) {
      case AttendanceHoursOrder.overtime:
        sorted.sort((AttendanceEmployeeHours a, AttendanceEmployeeHours b) {
          final int result = b.hours.overtimeHours.compareTo(a.hours.overtimeHours);
          return result != 0 ? result : byName(a, b);
        });
      case AttendanceHoursOrder.worked:
        sorted.sort((AttendanceEmployeeHours a, AttendanceEmployeeHours b) {
          final int result = b.hours.workedHours.compareTo(a.hours.workedHours);
          return result != 0 ? result : byName(a, b);
        });
      case AttendanceHoursOrder.name:
        sorted.sort(byName);
    }
    return sorted;
  }

  /// Worked hours of every row.
  double get totalWorkedHours =>
      rows.fold<double>(0, (double total, AttendanceEmployeeHours row) => total + row.hours.workedHours);

  /// Overtime hours of every row.
  double get totalOvertimeHours =>
      rows.fold<double>(0, (double total, AttendanceEmployeeHours row) => total + row.hours.overtimeHours);

  /// Copy with the given values replaced.
  AttendanceHoursUiState copyWith({
    AttendancePeriod? period,
    List<AttendanceArea>? areas,
    Object? selectedArea = _keep,
    bool? isLoadingAreas,
    bool? isLoading,
    List<AttendanceEmployeeHours>? rows,
    AttendanceHoursOrder? order,
    Object? errorMessage = _keep,
  }) {
    return AttendanceHoursUiState(
      period: period ?? this.period,
      areas: areas ?? this.areas,
      selectedArea: identical(selectedArea, _keep) ? this.selectedArea : selectedArea as AttendanceArea?,
      isLoadingAreas: isLoadingAreas ?? this.isLoadingAreas,
      isLoading: isLoading ?? this.isLoading,
      rows: rows ?? this.rows,
      order: order ?? this.order,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
    );
  }
}
