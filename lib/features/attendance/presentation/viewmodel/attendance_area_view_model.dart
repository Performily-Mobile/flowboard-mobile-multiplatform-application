import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/attendance/application/usecase/get_area_attendance_report_use_case.dart';
import 'package:flowboard/features/attendance/application/usecase/get_attendance_areas_use_case.dart';
import 'package:flowboard/features/attendance/domain/entity/area_attendance_report.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_area.dart';
import 'package:flowboard/features/attendance/domain/valueobject/attendance_period.dart';
import 'package:flowboard/features/attendance/presentation/state/attendance_area_ui_state.dart';
import 'package:flowboard/features/attendance/presentation/viewmodel/attendance_error_messages.dart';

/// View model of the area report: the totals of an area and its employees.
class AttendanceAreaViewModel extends ViewModel<AttendanceAreaUiState> {
  /// Creates the view model with the current month.
  AttendanceAreaViewModel({required this.getAttendanceAreas, required this.getAreaAttendanceReport})
      : super(AttendanceAreaUiState(period: AttendancePeriod.currentMonth()));

  final GetAttendanceAreasUseCase getAttendanceAreas;
  final GetAreaAttendanceReportUseCase getAreaAttendanceReport;

  /// Loads the areas, selects the first one and loads its report.
  Future<void> load() async {
    if (state.areas.isNotEmpty) return _loadReport();
    update((AttendanceAreaUiState s) => s.copyWith(isLoadingAreas: true, errorMessage: null));
    try {
      final List<AttendanceArea> areas = await getAttendanceAreas.execute();
      update((AttendanceAreaUiState s) => s.copyWith(
            isLoadingAreas: false,
            areas: areas,
            selectedArea: s.selectedArea ?? (areas.isEmpty ? null : areas.first),
          ));
      await _loadReport();
    } catch (error) {
      update((AttendanceAreaUiState s) => s.copyWith(
            isLoadingAreas: false,
            errorMessage: attendanceErrorMessage(error, 'No se pudieron cargar las áreas.'),
          ));
    }
  }

  /// Shows the report of [area].
  void onAreaSelected(AttendanceArea area) {
    if (area.id == state.selectedArea?.id) return;
    update((AttendanceAreaUiState s) => s.copyWith(selectedArea: area, report: null));
    _loadReport();
  }

  /// Shows the report of [period].
  void onPeriodSelected(AttendancePeriod period) {
    if (period == state.period) return;
    update((AttendanceAreaUiState s) => s.copyWith(period: period, report: null));
    _loadReport();
  }

  Future<void> _loadReport() async {
    final AttendanceArea? area = state.selectedArea;
    final AttendancePeriod period = state.period;
    if (area == null) return;
    update((AttendanceAreaUiState s) => s.copyWith(isLoading: s.report == null, errorMessage: null));
    try {
      final AreaAttendanceReport report = await getAreaAttendanceReport.execute(area.id, period);
      if (state.selectedArea?.id != area.id || state.period != period) return;
      update((AttendanceAreaUiState s) => s.copyWith(isLoading: false, report: report));
    } catch (error) {
      if (state.selectedArea?.id != area.id || state.period != period) return;
      update((AttendanceAreaUiState s) => s.copyWith(
            isLoading: false,
            errorMessage: attendanceErrorMessage(error, 'No se pudo cargar el reporte del área.'),
          ));
    }
  }
}
