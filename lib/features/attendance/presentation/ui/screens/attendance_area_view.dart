import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/collapsing_header_layout.dart';
import 'package:flowboard/core/designsystem/component/skeleton.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/features/attendance/domain/entity/area_attendance_report.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_area.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_employee.dart';
import 'package:flowboard/features/attendance/presentation/state/attendance_area_ui_state.dart';
import 'package:flowboard/features/attendance/presentation/ui/components/attendance_cards.dart';
import 'package:flowboard/features/attendance/presentation/ui/components/attendance_common.dart';
import 'package:flowboard/features/attendance/presentation/ui/components/attendance_fields.dart';
import 'package:flowboard/features/attendance/presentation/ui/navigation/attendance_navigation.dart';
import 'package:flowboard/features/attendance/presentation/viewmodel/attendance_area_view_model.dart';

/// Area report of the HR staff: the totals of the selected area and its employees, each of them
/// with their punctuality. An employee opens their attendance detail.
class AttendanceAreaView extends StatefulWidget {
  /// Creates the view; [leading] is shown at the top of the collapsing header (the section tabs).
  const AttendanceAreaView({super.key, this.leading});

  final Widget? leading;

  @override
  State<AttendanceAreaView> createState() => _AttendanceAreaViewState();
}

class _AttendanceAreaViewState extends State<AttendanceAreaView> {
  late final AttendanceAreaViewModel _viewModel = getIt<AttendanceAreaViewModel>();

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
        final AttendanceAreaUiState state = _viewModel.state;
        final AttendanceArea? area = state.selectedArea;
        return CollapsingHeaderLayout(
          showHeaderKey: Object.hash(area?.id, state.report == null, state.isLoading, state.errorMessage),
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

  Widget _buildContent(BuildContext context, AttendanceAreaUiState state, double headerHeight) {
    final EdgeInsets padding = EdgeInsets.fromLTRB(
      AppSpacing.screenHorizontal,
      headerHeight + 8,
      AppSpacing.screenHorizontal,
      AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
    );
    final AreaAttendanceReport? report = state.report;
    if ((state.isLoadingAreas || state.isLoading) && report == null) return SkeletonList(padding: padding);
    final String? errorMessage = state.errorMessage;
    if (errorMessage != null && report == null) {
      return ListView(
        padding: padding,
        children: <Widget>[
          AttendanceMessageState(
            title: 'No se pudo cargar el reporte',
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
            message: 'Crea las áreas de la empresa en Organización para ver su asistencia.',
          ),
        ],
      );
    }
    if (report == null) return SkeletonList(padding: padding);
    final List<AttendanceEmployee> employees = report.employees;
    return RefreshIndicator(
      onRefresh: _viewModel.load,
      edgeOffset: headerHeight,
      child: ListView(
        padding: padding,
        children: <Widget>[
          AttendanceMetricGrid.area(report.summary),
          const SizedBox(height: AppSpacing.l),
          AttendanceSectionHeader(text: 'Colaboradores (${employees.length})'),
          const SizedBox(height: AppSpacing.m),
          if (employees.isEmpty)
            const AttendanceMessageState(
              title: 'El área no tiene colaboradores activos',
              message: 'Cuando se asigne personal al área, aparecerá aquí.',
            )
          else
            for (final AttendanceEmployee employee in employees)
              Padding(
                key: ValueKey<int>(employee.id),
                padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
                child: AttendanceEmployeeRow(
                  employee: employee,
                  totals: report.totalsOf(employee.id),
                  onTap: () => _openEmployee(employee.id),
                ),
              ),
        ],
      ),
    );
  }
}
