import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/collapsing_header_layout.dart';
import 'package:flowboard/core/designsystem/component/skeleton.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_area.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_employee_hours.dart';
import 'package:flowboard/features/attendance/presentation/state/attendance_filters.dart';
import 'package:flowboard/features/attendance/presentation/state/attendance_hours_ui_state.dart';
import 'package:flowboard/features/attendance/presentation/ui/components/attendance_cards.dart';
import 'package:flowboard/features/attendance/presentation/ui/components/attendance_common.dart';
import 'package:flowboard/features/attendance/presentation/ui/components/attendance_fields.dart';
import 'package:flowboard/features/attendance/presentation/ui/components/attendance_formatters.dart';
import 'package:flowboard/features/attendance/presentation/ui/navigation/attendance_navigation.dart';
import 'package:flowboard/features/attendance/presentation/viewmodel/attendance_hours_view_model.dart';

/// Hours section of the HR staff: worked and overtime hours of the employees of one area, with the
/// totals of the area. An employee opens their attendance detail.
class AttendanceHoursView extends StatefulWidget {
  /// Creates the view; [leading] is shown at the top of the collapsing header (the section tabs).
  const AttendanceHoursView({super.key, this.leading});

  final Widget? leading;

  @override
  State<AttendanceHoursView> createState() => _AttendanceHoursViewState();
}

class _AttendanceHoursViewState extends State<AttendanceHoursView> {
  late final AttendanceHoursViewModel _viewModel = getIt<AttendanceHoursViewModel>();

  @override
  void initState() {
    super.initState();
    _viewModel.load();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _openEmployee(int employeeId) {
    Navigator.of(context).pushNamed(
      AttendanceRoutes.employeeAttendance,
      arguments: EmployeeAttendanceArgs(employeeId: employeeId, period: _viewModel.state.period),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        final AttendanceHoursUiState state = _viewModel.state;
        final AttendanceArea? area = state.selectedArea;
        return CollapsingHeaderLayout(
          showHeaderKey: Object.hash(area?.id, state.rows.length, state.isLoading, state.errorMessage),
          header: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.m,
              children: <Widget>[
                ?widget.leading,
                AttendanceChipRow(
                  children: <Widget>[
                    if (state.areas.isNotEmpty)
                      AttendanceMenuChip<AttendanceArea>(
                        label: 'Área: ${area?.name ?? 'elige una'}',
                        options: state.areas,
                        optionLabel: (AttendanceArea option) => option.name,
                        onSelect: _viewModel.onAreaSelected,
                      ),
                    AttendancePeriodChip(period: state.period, onSelect: _viewModel.onPeriodSelected),
                    AttendanceMenuChip<AttendanceHoursOrder>(
                      label: 'Orden: ${state.order.label.toLowerCase()}',
                      selected: false,
                      options: AttendanceHoursOrder.values,
                      optionLabel: (AttendanceHoursOrder order) => order.label,
                      onSelect: _viewModel.onOrderSelected,
                    ),
                  ],
                ),
              ],
            ),
          ),
          contentBuilder: (BuildContext context, EdgeInsets contentPadding) =>
              _buildContent(context, state, contentPadding.top),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, AttendanceHoursUiState state, double headerHeight) {
    final EdgeInsets padding = EdgeInsets.fromLTRB(
      AppSpacing.screenHorizontal,
      headerHeight + 8,
      AppSpacing.screenHorizontal,
      AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
    );
    if ((state.isLoadingAreas || state.isLoading) && state.rows.isEmpty) return SkeletonList(padding: padding);
    final String? errorMessage = state.errorMessage;
    if (errorMessage != null && state.rows.isEmpty) {
      return ListView(
        padding: padding,
        children: <Widget>[
          AttendanceMessageState(
            title: 'No se pudo cargar el reporte de horas',
            message: errorMessage,
            actionLabel: 'Reintentar',
            onAction: _viewModel.load,
          ),
        ],
      );
    }
    if (state.areas.isEmpty) {
      return ListView(
        padding: padding,
        children: const <Widget>[
          AttendanceMessageState(
            title: 'No hay áreas activas',
            message: 'Crea las áreas de la empresa en Organización para ver sus horas.',
          ),
        ],
      );
    }
    final List<AttendanceEmployeeHours> rows = state.sortedRows;
    return RefreshIndicator(
      onRefresh: _viewModel.load,
      edgeOffset: headerHeight,
      child: ListView(
        padding: padding,
        children: <Widget>[
          AttendanceMetricGrid(
            metrics: <AttendanceMetric>[
              AttendanceMetric('Horas trabajadas', AttendanceFormatters.hours(state.totalWorkedHours)),
              AttendanceMetric('Sobretiempo', AttendanceFormatters.hours(state.totalOvertimeHours)),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          const AttendanceBanner(
            message: 'Las horas se calculan por colaborador con las marcaciones del periodo.',
            icon: FlowboardIcons.info,
          ),
          const SizedBox(height: AppSpacing.l),
          AttendanceSectionHeader(text: 'Colaboradores (${rows.length})'),
          const SizedBox(height: AppSpacing.m),
          if (rows.isEmpty)
            const AttendanceMessageState(
              title: 'El área no tiene colaboradores activos',
              message: 'Cuando se asigne personal al área, aparecerá aquí.',
            )
          else
            for (final AttendanceEmployeeHours row in rows)
              Padding(
                key: ValueKey<int>(row.employee.id),
                padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
                child: AttendanceHoursRow(row: row, onTap: () => _openEmployee(row.employee.id)),
              ),
        ],
      ),
    );
  }
}
