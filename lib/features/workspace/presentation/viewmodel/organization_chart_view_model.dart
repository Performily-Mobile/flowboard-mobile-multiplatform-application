import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/workspace/application/usecase/get_areas_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_organization_chart_use_case.dart';
import 'package:flowboard/features/workspace/domain/entity/area.dart';
import 'package:flowboard/features/workspace/domain/valueobject/organization_chart.dart';
import 'package:flowboard/features/workspace/presentation/state/organization_chart_ui_state.dart';
import 'package:flowboard/features/workspace/presentation/viewmodel/workspace_error_messages.dart';

/// View model of the organization chart.
class OrganizationChartViewModel extends ViewModel<OrganizationChartUiState> {
  /// Creates the view model and loads the active areas.
  OrganizationChartViewModel({required this.getOrganizationChart, required this.getAreas})
      : super(const OrganizationChartUiState()) {
    _loadAreas();
  }

  final GetOrganizationChartUseCase getOrganizationChart;
  final GetAreasUseCase getAreas;

  bool _initialized = false;
  int _request = 0;

  /// Called once when the screen opens.
  ///
  /// When an area arrives the chart opens directly on "Por área" (employee view, MA-17) and the
  /// given employee is highlighted with "(tú)".
  void initialize(int? areaId, int? highlightedEmployeeId) {
    if (_initialized) return;
    _initialized = true;
    update((OrganizationChartUiState s) => s.copyWith(
          mode: areaId != null ? OrganizationChartMode.byArea : OrganizationChartMode.wholeOrganization,
          selectedAreaId: areaId,
          highlightedEmployeeId: highlightedEmployeeId == null ? null : EmployeeId(highlightedEmployeeId),
        ));
    loadChart();
  }

  /// Switches between the whole organization and one area.
  void onModeChange(OrganizationChartMode mode) {
    update((OrganizationChartUiState s) => s.copyWith(
          mode: mode,
          selectedAreaId: mode == OrganizationChartMode.byArea
              ? s.selectedAreaId ?? (s.areas.isEmpty ? null : s.areas.first.id)
              : s.selectedAreaId,
        ));
    loadChart();
  }

  /// Shows the chart of the area [areaId].
  void onAreaSelected(int areaId) {
    update((OrganizationChartUiState s) => s.copyWith(selectedAreaId: areaId));
    loadChart();
  }

  /// Loads the chart of the current scope.
  Future<void> loadChart() async {
    final int request = ++_request;
    final OrganizationChartUiState current = state;
    final int? areaId = current.mode == OrganizationChartMode.byArea ? current.selectedAreaId : null;
    update((OrganizationChartUiState s) => s.copyWith(isLoading: true, errorMessage: null));
    try {
      final OrganizationChart chart = await getOrganizationChart.execute(areaId: areaId);
      if (request != _request) return;
      update((OrganizationChartUiState s) => s.copyWith(isLoading: false, chart: chart));
    } catch (error) {
      if (request != _request) return;
      update((OrganizationChartUiState s) =>
          s.copyWith(isLoading: false, errorMessage: workspaceErrorMessage(error)));
    }
  }

  Future<void> _loadAreas() async {
    final List<Area>? areas = await attemptOrNull(() => getAreas.execute(onlyActive: true));
    if (areas != null) update((OrganizationChartUiState s) => s.copyWith(areas: areas));
  }
}
