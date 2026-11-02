import 'package:flowboard/features/workspace/domain/entity/area.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/domain/entity/position.dart';
import 'package:flowboard/features/workspace/domain/valueobject/employment_status.dart';

const Object _keep = Object();

/// State of the employee list.
class EmployeesUiState {
  /// Creates the state; the list starts filtered by active employees.
  const EmployeesUiState({
    this.isLoading = false,
    this.employees = const <Employee>[],
    this.query = '',
    this.areas = const <Area>[],
    this.positions = const <Position>[],
    this.selectedArea,
    this.selectedStatus = EmploymentStatus.active,
    this.selectedPosition,
    this.errorMessage,
  });

  final bool isLoading;
  final List<Employee> employees;
  final String query;
  final List<Area> areas;
  final List<Position> positions;
  final Area? selectedArea;
  final EmploymentStatus? selectedStatus;
  final Position? selectedPosition;
  final String? errorMessage;

  /// True when a search text or a filter is active.
  bool get hasFilters =>
      query.trim().isNotEmpty || selectedArea != null || selectedStatus != null || selectedPosition != null;

  /// Positions offered by the position filter: those of the selected area, or all of them.
  List<Position> get positionsForFilter {
    final Area? area = selectedArea;
    if (area == null) return positions;
    return positions.where((Position position) => position.belongsTo(area.id)).toList();
  }

  /// Copy with the given values replaced.
  EmployeesUiState copyWith({
    bool? isLoading,
    List<Employee>? employees,
    String? query,
    List<Area>? areas,
    List<Position>? positions,
    Object? selectedArea = _keep,
    Object? selectedStatus = _keep,
    Object? selectedPosition = _keep,
    Object? errorMessage = _keep,
  }) {
    return EmployeesUiState(
      isLoading: isLoading ?? this.isLoading,
      employees: employees ?? this.employees,
      query: query ?? this.query,
      areas: areas ?? this.areas,
      positions: positions ?? this.positions,
      selectedArea: identical(selectedArea, _keep) ? this.selectedArea : selectedArea as Area?,
      selectedStatus: identical(selectedStatus, _keep) ? this.selectedStatus : selectedStatus as EmploymentStatus?,
      selectedPosition: identical(selectedPosition, _keep) ? this.selectedPosition : selectedPosition as Position?,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
    );
  }
}
