import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/attendance/application/usecase/get_area_hours_report_use_case.dart';
import 'package:flowboard/features/attendance/application/usecase/get_attendance_areas_use_case.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_area.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_employee_hours.dart';
import 'package:flowboard/features/attendance/domain/valueobject/attendance_period.dart';
import 'package:flowboard/features/attendance/presentation/state/attendance_filters.dart';
import 'package:flowboard/features/attendance/presentation/state/attendance_hours_ui_state.dart';
import 'package:flowboard/features/attendance/presentation/viewmodel/attendance_error_messages.dart';

/// View model of the hours report: worked and overtime hours of the employees of one area.
class AttendanceHoursViewModel extends ViewModel<AttendanceHoursUiState> {
  /// Creates the view model with the current month.
  AttendanceHoursViewModel({required this.getAttendanceAreas, required this.getAreaHoursReport})
      : super(AttendanceHoursUiState(period: AttendancePeriod.currentMonth()));

  final GetAttendanceAreasUseCase getAttendanceAreas;
  final GetAreaHoursReportUseCase getAreaHoursReport;

  /// Loads the areas, selects the first one and loads its hours.
  Future<void> load() async {
    if (state.areas.isNotEmpty) return _loadRows();
    update((AttendanceHoursUiState s) => s.copyWith(isLoadingAreas: true, errorMessage: null));
    try {
      final List<AttendanceArea> areas = await getAttendanceAreas.execute();
      update((AttendanceHoursUiState s) => s.copyWith(
            isLoadingAreas: false,
            areas: areas,
            selectedArea: s.selectedArea ?? (areas.isEmpty ? null : areas.first),
          ));
      await _loadRows();
    } catch (error) {
      update((AttendanceHoursUiState s) => s.copyWith(
            isLoadingAreas: false,
            errorMessage: attendanceErrorMessage(error, 'No se pudieron cargar las áreas.'),
          ));
    }
  }

  /// Shows the hours of [area].
  void onAreaSelected(AttendanceArea area) {
    if (area.id == state.selectedArea?.id) return;
    update((AttendanceHoursUiState s) => s.copyWith(selectedArea: area, rows: const <AttendanceEmployeeHours>[]));
    _loadRows();
  }

  /// Shows the hours of [period].
  void onPeriodSelected(AttendancePeriod period) {
    if (period == state.period) return;
    update((AttendanceHoursUiState s) => s.copyWith(period: period, rows: const <AttendanceEmployeeHours>[]));
    _loadRows();
  }

  /// Orders the rows; the data is not asked again.
  void onOrderSelected(AttendanceHoursOrder order) => update((AttendanceHoursUiState s) => s.copyWith(order: order));

  Future<void> _loadRows() async {
    final AttendanceArea? area = state.selectedArea;
    final AttendancePeriod period = state.period;
    if (area == null) return;
    update((AttendanceHoursUiState s) => s.copyWith(isLoading: s.rows.isEmpty, errorMessage: null));
    try {
      final List<AttendanceEmployeeHours> rows = await getAreaHoursReport.execute(area.id, period);
      if (state.selectedArea?.id != area.id || state.period != period) return;
      update((AttendanceHoursUiState s) => s.copyWith(isLoading: false, rows: rows));
    } catch (error) {
      if (state.selectedArea?.id != area.id || state.period != period) return;
      update((AttendanceHoursUiState s) => s.copyWith(
            isLoading: false,
            errorMessage: attendanceErrorMessage(error, 'No se pudo cargar el reporte de horas.'),
          ));
    }
  }
}
