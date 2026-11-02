import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/features/workspace/domain/entity/area.dart';
import 'package:flowboard/features/workspace/domain/valueobject/organization_chart.dart';

const Object _keep = Object();

/// Scope of the organization chart.
enum OrganizationChartMode { wholeOrganization, byArea }

/// State of the organization chart.
class OrganizationChartUiState {
  /// Creates the state.
  const OrganizationChartUiState({
    this.isLoading = false,
    this.mode = OrganizationChartMode.wholeOrganization,
    this.areas = const <Area>[],
    this.selectedAreaId,
    this.chart,
    this.highlightedEmployeeId,
    this.errorMessage,
  });

  final bool isLoading;
  final OrganizationChartMode mode;
  final List<Area> areas;
  final int? selectedAreaId;
  final OrganizationChart? chart;
  final EmployeeId? highlightedEmployeeId;
  final String? errorMessage;

  /// Copy with the given values replaced.
  OrganizationChartUiState copyWith({
    bool? isLoading,
    OrganizationChartMode? mode,
    List<Area>? areas,
    Object? selectedAreaId = _keep,
    Object? chart = _keep,
    Object? highlightedEmployeeId = _keep,
    Object? errorMessage = _keep,
  }) {
    return OrganizationChartUiState(
      isLoading: isLoading ?? this.isLoading,
      mode: mode ?? this.mode,
      areas: areas ?? this.areas,
      selectedAreaId: identical(selectedAreaId, _keep) ? this.selectedAreaId : selectedAreaId as int?,
      chart: identical(chart, _keep) ? this.chart : chart as OrganizationChart?,
      highlightedEmployeeId:
          identical(highlightedEmployeeId, _keep) ? this.highlightedEmployeeId : highlightedEmployeeId as EmployeeId?,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
    );
  }
}
