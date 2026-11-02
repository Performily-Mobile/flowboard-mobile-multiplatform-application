import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/skeleton.dart';
import 'package:flowboard/core/designsystem/component/collapsing_header_layout.dart';
import 'package:flowboard/core/designsystem/component/flowboard_overflow_menu.dart';
import 'package:flowboard/core/designsystem/component/flowboard_search_field.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/features/workspace/domain/entity/area.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/domain/entity/position.dart';
import 'package:flowboard/features/workspace/domain/valueobject/employment_status.dart';
import 'package:flowboard/features/workspace/presentation/state/employees_ui_state.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/employee_list_item.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/message_state.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/workspace_labels.dart';
import 'package:flowboard/features/workspace/presentation/ui/navigation/workspace_navigation.dart';
import 'package:flowboard/features/workspace/presentation/viewmodel/employees_view_model.dart';

/// List of employees with a search box and filters that slide away while scrolling down.
class EmployeesScreen extends StatefulWidget {
  /// Creates the screen.
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  late final EmployeesViewModel _viewModel = getIt<EmployeesViewModel>();
  bool _fabExpanded = true;

  @override
  void initState() {
    super.initState();
    _viewModel.loadEmployees();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openEmployee(int employeeId) async {
    await Navigator.of(context).pushNamed(
      WorkspaceRoutes.employeeDetail,
      arguments: EmployeeDetailArgs(employeeId: employeeId),
    );
    if (mounted) _viewModel.loadEmployees();
  }

  Future<void> _register() async {
    final Object? result = await Navigator.of(context, rootNavigator: true).pushNamed(WorkspaceRoutes.registerEmployee);
    if (!mounted) return;
    if (result is int) {
      await _openEmployee(result);
    } else {
      _viewModel.loadEmployees();
    }
  }

  Future<void> _push(String route, {Object? arguments}) async {
    await Navigator.of(context).pushNamed(route, arguments: arguments);
    if (mounted) _viewModel.loadEmployees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _register,
        isExtended: _fabExpanded,
        tooltip: 'Nuevo colaborador',
        icon: const Icon(FlowboardIcons.add),
        label: const Text('Nuevo colaborador'),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (BuildContext context, Widget? child) {
          final EmployeesUiState state = _viewModel.state;
          return Column(
            children: <Widget>[
              FlowboardTopBar(
                title: 'Colaboradores',
                actions: <Widget>[
                  FlowboardOverflowMenu(
                    actions: <FlowboardMenuAction>[
                      FlowboardMenuAction(
                        label: 'Áreas y posiciones',
                        onSelected: () => _push(WorkspaceRoutes.organization),
                      ),
                      FlowboardMenuAction(
                        label: 'Organigrama',
                        onSelected: () =>
                            _push(WorkspaceRoutes.organizationChart, arguments: const OrganizationChartArgs()),
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: CollapsingHeaderLayout(
                  showHeaderKey: Object.hash(state.employees.length, state.errorMessage != null),
                  onHeaderVisibilityChanged: (bool visible) => setState(() => _fabExpanded = visible),
                  header: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 4, AppSpacing.screenHorizontal, 12),
                    child: Column(
                      spacing: AppSpacing.m,
                      children: <Widget>[
                        FlowboardSearchField(
                          query: state.query,
                          onQueryChange: _viewModel.onQueryChange,
                          placeholder: 'Buscar por nombre, apellido o DNI',
                        ),
                        _EmployeeFilters(
                          state: state,
                          onAreaSelected: _viewModel.onAreaSelected,
                          onStatusSelected: _viewModel.onStatusSelected,
                          onPositionSelected: _viewModel.onPositionSelected,
                        ),
                      ],
                    ),
                  ),
                  contentBuilder: (BuildContext context, EdgeInsets contentPadding) =>
                      _buildContent(context, state, contentPadding.top),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, EmployeesUiState state, double headerHeight) {
    if (state.isLoading && state.employees.isEmpty) {
      return SkeletonList(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          headerHeight + 4,
          AppSpacing.screenHorizontal,
          0,
        ),
      );
    }
    final String? errorMessage = state.errorMessage;
    if (errorMessage != null) {
      return MessageState(
        title: 'No se pudo cargar la lista',
        message: errorMessage,
        actionLabel: 'Reintentar',
        onAction: _viewModel.loadEmployees,
        topPadding: headerHeight + 48,
      );
    }
    if (state.employees.isEmpty) {
      return MessageState(
        title: 'No encontramos colaboradores',
        message: _emptyMessage(state),
        actionLabel: state.hasFilters ? 'Limpiar filtros' : null,
        onAction: _viewModel.clearFilters,
        topPadding: headerHeight + 48,
      );
    }
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        headerHeight + 4,
        AppSpacing.screenHorizontal,
        AppSpacing.fabClearance + bottomInset,
      ),
      itemCount: state.employees.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(left: 4, right: 4, bottom: AppSpacing.itemGap),
            child: Text(
              '${state.employees.length} colaboradores',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          );
        }
        final Employee employee = state.employees[index - 1];
        return Padding(
          key: ValueKey<int>(employee.id.value),
          padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
          child: EmployeeListItem(employee: employee, onClick: () => _openEmployee(employee.id.value)),
        );
      },
    );
  }

  String _emptyMessage(EmployeesUiState state) {
    if (!state.hasFilters) return 'Todavía no hay colaboradores registrados.';
    final List<String> parts = <String>[
      if (state.query.trim().isNotEmpty) 'coincide con "${state.query}"',
      if (state.selectedArea != null) 'en ${state.selectedArea!.name}',
      if (state.selectedPosition != null) 'con puesto ${state.selectedPosition!.title}',
      if (state.selectedStatus != null) 'con estado ${state.selectedStatus!.label}',
    ];
    return 'Ningún registro ${parts.join(' ')}.';
  }
}

/// Single row of filter chips (area, status, position) that scrolls sideways when it does not fit.
class _EmployeeFilters extends StatelessWidget {
  const _EmployeeFilters({
    required this.state,
    required this.onAreaSelected,
    required this.onStatusSelected,
    required this.onPositionSelected,
  });

  final EmployeesUiState state;
  final ValueChanged<Area?> onAreaSelected;
  final ValueChanged<EmploymentStatus?> onStatusSelected;
  final ValueChanged<Position?> onPositionSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: AppSpacing.s,
        children: <Widget>[
          _FilterMenuChip<Area>(
            name: 'Área',
            selectedLabel: state.selectedArea?.name,
            options: state.areas,
            optionLabel: (Area area) => area.name,
            onSelect: onAreaSelected,
            onClear: () => onAreaSelected(null),
          ),
          _FilterMenuChip<EmploymentStatus>(
            name: 'Estado',
            selectedLabel: state.selectedStatus?.label,
            options: EmploymentStatus.values,
            optionLabel: (EmploymentStatus status) => status.label,
            onSelect: onStatusSelected,
            onClear: () => onStatusSelected(null),
          ),
          _FilterMenuChip<Position>(
            name: 'Puesto',
            selectedLabel: state.selectedPosition?.title,
            options: state.positionsForFilter,
            optionLabel: (Position position) => position.title,
            onSelect: onPositionSelected,
            onClear: () => onPositionSelected(null),
          ),
        ],
      ),
    );
  }
}

/// Filter chip that opens a menu of options; when a value is selected, tapping it clears the filter.
class _FilterMenuChip<T> extends StatelessWidget {
  const _FilterMenuChip({
    required this.name,
    required this.selectedLabel,
    required this.options,
    required this.optionLabel,
    required this.onSelect,
    required this.onClear,
  });

  final String name;
  final String? selectedLabel;
  final List<T> options;
  final String Function(T option) optionLabel;
  final ValueChanged<T> onSelect;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final bool selected = selectedLabel != null;
    return MenuAnchor(
      menuChildren: <Widget>[
        for (final T option in options)
          MenuItemButton(onPressed: () => onSelect(option), child: Text(optionLabel(option))),
      ],
      builder: (BuildContext context, MenuController controller, Widget? child) {
        void openMenu() => controller.isOpen ? controller.close() : controller.open();
        return FilterChip(
          selected: selected,
          showCheckmark: true,
          label: Text(selected ? '$name: $selectedLabel' : name),
          onSelected: (bool _) => selected ? onClear() : openMenu(),
          deleteIcon: Icon(selected ? FlowboardIcons.close : FlowboardIcons.arrowDropDown, size: 18),
          deleteButtonTooltipMessage: selected ? 'Quitar filtro' : name,
          onDeleted: selected ? onClear : openMenu,
        );
      },
    );
  }
}
