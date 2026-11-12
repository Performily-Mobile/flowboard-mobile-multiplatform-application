import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/collapsing_header_layout.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/component/skeleton.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_employee.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/entity/employee_attendance.dart';
import 'package:flowboard/features/attendance/domain/valueobject/attendance_period.dart';
import 'package:flowboard/features/attendance/presentation/state/attendance_filters.dart';
import 'package:flowboard/features/attendance/presentation/state/employee_attendance_ui_state.dart';
import 'package:flowboard/features/attendance/presentation/ui/components/attendance_cards.dart';
import 'package:flowboard/features/attendance/presentation/ui/components/attendance_common.dart';
import 'package:flowboard/features/attendance/presentation/ui/components/attendance_fields.dart';
import 'package:flowboard/features/attendance/presentation/viewmodel/employee_attendance_view_model.dart';

/// Attendance detail of one employee for the HR staff: their totals and their records of a period.
class EmployeeAttendanceScreen extends StatefulWidget {
  /// Creates the screen of the employee [employeeId], starting with [period].
  const EmployeeAttendanceScreen({super.key, required this.employeeId, required this.period});

  final int employeeId;
  final AttendancePeriod period;

  @override
  State<EmployeeAttendanceScreen> createState() => _EmployeeAttendanceScreenState();
}

class _EmployeeAttendanceScreenState extends State<EmployeeAttendanceScreen> {
  late final EmployeeAttendanceViewModel _viewModel = getIt<EmployeeAttendanceViewModel>();

  @override
  void initState() {
    super.initState();
    _viewModel.load(widget.employeeId, period: widget.period);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        final EmployeeAttendanceUiState state = _viewModel.state;
        final AttendanceEmployee? employee = state.attendance?.employee;
        return Scaffold(
          body: Column(
            children: <Widget>[
              FlowboardTopBar(
                title: state.title,
                subtitle: employee == null ? null : '${employee.positionTitle} · ${employee.areaName}',
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: CollapsingHeaderLayout(
                  showHeaderKey: Object.hash(state.statusFilter, state.records.length, state.isLoading),
                  header: Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: AppSpacing.m),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: AppSpacing.m,
                      children: <Widget>[
                        AttendanceChipRow(
                          children: <Widget>[
                            AttendancePeriodChip(period: state.period, onSelect: _viewModel.onPeriodSelected),
                          ],
                        ),
                        AttendanceStatusFilterChips(
                          selected: state.statusFilter,
                          onSelect: _viewModel.onStatusFilterSelected,
                        ),
                      ],
                    ),
                  ),
                  contentBuilder: (BuildContext context, EdgeInsets contentPadding) =>
                      _buildContent(context, state, contentPadding.top),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, EmployeeAttendanceUiState state, double headerHeight) {
    final EdgeInsets padding = EdgeInsets.fromLTRB(
      AppSpacing.screenHorizontal,
      headerHeight + 8,
      AppSpacing.screenHorizontal,
      AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
    );
    final EmployeeAttendance? attendance = state.attendance;
    if (state.isLoading && attendance == null) return SkeletonList(padding: padding, showAvatar: false);
    final String? errorMessage = state.errorMessage;
    if (attendance == null) {
      return ListView(
        padding: padding,
        children: <Widget>[
          AttendanceMessageState(
            title: 'No se pudo cargar la asistencia',
            message: errorMessage ?? 'Inténtalo de nuevo.',
            actionLabel: 'Reintentar',
            onAction: _viewModel.retry,
          ),
        ],
      );
    }
    final List<AttendanceRecord> records = state.records;
    return RefreshIndicator(
      onRefresh: () async => _viewModel.retry(),
      edgeOffset: headerHeight,
      child: ListView(
        padding: padding,
        children: <Widget>[
          AttendanceMetricGrid.totals(attendance.totals),
          const SizedBox(height: AppSpacing.l),
          const AttendanceSectionHeader(text: 'Registros del periodo'),
          const SizedBox(height: AppSpacing.m),
          if (records.isEmpty)
            AttendanceMessageState(
              title: state.statusFilter == AttendanceStatusFilter.all
                  ? 'No hay registros en este periodo'
                  : 'No hay registros con este estado',
              message: state.statusFilter == AttendanceStatusFilter.all
                  ? 'Prueba con otro periodo.'
                  : 'Prueba con otro filtro.',
            )
          else
            for (final AttendanceRecord record in records)
              Padding(
                key: ValueKey<String>('${record.id}-${record.workDate}'),
                padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
                child: AttendanceRecordCard(record: record),
              ),
        ],
      ),
    );
  }
}
