import 'dart:async';

import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/workspace/application/usecase/get_areas_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_employees_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_positions_use_case.dart';
import 'package:flowboard/features/workspace/domain/entity/area.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/domain/entity/position.dart';
import 'package:flowboard/features/workspace/domain/valueobject/employment_status.dart';
import 'package:flowboard/features/workspace/presentation/state/employees_ui_state.dart';
import 'package:flowboard/features/workspace/presentation/viewmodel/workspace_error_messages.dart';

/// View model of the employee list, with search and filters.
class EmployeesViewModel extends ViewModel<EmployeesUiState> {
  /// Creates the view model and loads the filter options.
  EmployeesViewModel({required this.getEmployees, required this.getAreas, required this.getPositions})
      : super(const EmployeesUiState()) {
    _loadFilterOptions();
  }

  final GetEmployeesUseCase getEmployees;
  final GetAreasUseCase getAreas;
  final GetPositionsUseCase getPositions;

  static const Duration _searchDebounce = Duration(milliseconds: 400);

  Timer? _searchTimer;
  int _request = 0;

  /// Loads the list with the current search and filters.
  void loadEmployees() {
    _searchTimer?.cancel();
    _fetchEmployees();
  }

  /// Changes the search text and searches after a short pause.
  void onQueryChange(String query) {
    update((EmployeesUiState s) => s.copyWith(query: query));
    _searchTimer?.cancel();
    _searchTimer = Timer(_searchDebounce, _fetchEmployees);
  }

  /// Filters by [area]; a selected position of another area is cleared.
  void onAreaSelected(Area? area) {
    update((EmployeesUiState s) {
      final bool keepPosition = area == null || s.selectedPosition?.belongsTo(area.id) == true;
      return s.copyWith(selectedArea: area, selectedPosition: keepPosition ? s.selectedPosition : null);
    });
    loadEmployees();
  }

  /// Filters by [status].
  void onStatusSelected(EmploymentStatus? status) {
    update((EmployeesUiState s) => s.copyWith(selectedStatus: status));
    loadEmployees();
  }

  /// Filters by [position].
  void onPositionSelected(Position? position) {
    update((EmployeesUiState s) => s.copyWith(selectedPosition: position));
    loadEmployees();
  }

  /// Clears the search text and every filter.
  void clearFilters() {
    update((EmployeesUiState s) =>
        s.copyWith(query: '', selectedArea: null, selectedStatus: null, selectedPosition: null));
    loadEmployees();
  }

  Future<void> _fetchEmployees() async {
    final int request = ++_request;
    final EmployeesUiState current = state;
    update((EmployeesUiState s) => s.copyWith(isLoading: true, errorMessage: null));
    try {
      final List<Employee> employees = await getEmployees.execute(
        search: current.query,
        areaId: current.selectedArea?.id,
        status: current.selectedStatus,
        positionId: current.selectedPosition?.id,
      );
      if (request != _request) return;
      update((EmployeesUiState s) => s.copyWith(isLoading: false, employees: employees));
    } catch (error) {
      if (request != _request) return;
      update((EmployeesUiState s) => s.copyWith(isLoading: false, errorMessage: workspaceErrorMessage(error)));
    }
  }

  Future<void> _loadFilterOptions() async {
    final List<Area>? areas = await attemptOrNull(() => getAreas.execute(onlyActive: true));
    if (areas != null) update((EmployeesUiState s) => s.copyWith(areas: areas));
    final List<Position>? positions = await attemptOrNull(() => getPositions.execute(onlyActive: true));
    if (positions != null) update((EmployeesUiState s) => s.copyWith(positions: positions));
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }
}
