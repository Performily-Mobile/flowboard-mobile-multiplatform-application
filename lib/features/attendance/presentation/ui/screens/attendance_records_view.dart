import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/collapsing_header_layout.dart';
import 'package:flowboard/core/designsystem/component/skeleton.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/presentation/state/attendance_filters.dart';
import 'package:flowboard/features/attendance/presentation/state/attendance_records_ui_state.dart';
import 'package:flowboard/features/attendance/presentation/ui/components/attendance_cards.dart';
import 'package:flowboard/features/attendance/presentation/ui/components/attendance_common.dart';
import 'package:flowboard/features/attendance/presentation/ui/components/attendance_fields.dart';
import 'package:flowboard/features/attendance/presentation/ui/navigation/attendance_navigation.dart';
import 'package:flowboard/features/attendance/presentation/viewmodel/attendance_records_view_model.dart';

/// Records section of the HR staff: the attendance of the whole staff, by period and status, loaded
/// page by page while the list scrolls. A record opens the attendance of its employee.
class AttendanceRecordsView extends StatefulWidget {
  /// Creates the view; [leading] is shown at the top of the collapsing header (the section tabs).
  const AttendanceRecordsView({super.key, this.leading});

  final Widget? leading;

  @override
  State<AttendanceRecordsView> createState() => _AttendanceRecordsViewState();
}

class _AttendanceRecordsViewState extends State<AttendanceRecordsView> {
  late final AttendanceRecordsViewModel _viewModel = getIt<AttendanceRecordsViewModel>();

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
        final AttendanceRecordsUiState state = _viewModel.state;
        return CollapsingHeaderLayout(
          showHeaderKey: Object.hash(state.statusFilter, state.records.length, state.isLoading, state.errorMessage),
          header: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.m,
              children: <Widget>[
                ?widget.leading,
                AttendanceChipRow(
                  children: <Widget>[
                    AttendancePeriodChip(period: state.period, onSelect: _viewModel.onPeriodSelected),
                  ],
                ),
                AttendanceStatusFilterChips(selected: state.statusFilter, onSelect: _viewModel.onStatusFilterSelected),
              ],
            ),
          ),
          contentBuilder: (BuildContext context, EdgeInsets contentPadding) =>
              _buildContent(context, state, contentPadding.top),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, AttendanceRecordsUiState state, double headerHeight) {
    final EdgeInsets padding = EdgeInsets.fromLTRB(
      AppSpacing.screenHorizontal,
      headerHeight + 8,
      AppSpacing.screenHorizontal,
      AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
    );
    if (state.isLoading && state.records.isEmpty) return SkeletonList(padding: padding);
    final String? errorMessage = state.errorMessage;
    if (errorMessage != null && state.records.isEmpty) {
      return ListView(
        padding: padding,
        children: <Widget>[
          AttendanceMessageState(
            title: 'No se pudieron cargar los registros',
            message: errorMessage,
            actionLabel: 'Reintentar',
            onAction: _viewModel.load,
          ),
        ],
      );
    }
    if (state.records.isEmpty) {
      final bool all = state.statusFilter == AttendanceStatusFilter.all;
      return ListView(
        padding: padding,
        children: <Widget>[
          AttendanceMessageState(
            title: all ? 'No hay registros en este periodo' : 'No hay registros con este estado',
            message: all ? 'Prueba con otro periodo.' : 'Prueba con otro filtro.',
          ),
        ],
      );
    }
    final List<AttendanceRecord> records = state.records;
    return RefreshIndicator(
      onRefresh: _viewModel.load,
      edgeOffset: headerHeight,
      child: ListView.builder(
        padding: padding,
        itemCount: records.length + 1 + (state.paging.hasMore ? 1 : 0),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.m),
              child: AttendanceSectionHeader(text: state.total == 1 ? '1 registro' : '${state.total} registros'),
            );
          }
          final int position = index - 1;
          if (position == records.length) {
            return AttendanceLoadMoreItem(
              itemCount: records.length,
              failed: state.paging.loadMoreFailed,
              onLoadMore: _viewModel.loadMore,
            );
          }
          final AttendanceRecord record = records[position];
          return Padding(
            key: ValueKey<String>('${record.id}-${record.employeeId}-${record.workDate}'),
            padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
            child: AttendanceRecordCard(
              record: record,
              showEmployee: true,
              onTap: () => _openEmployee(record.employeeId),
            ),
          );
        },
      ),
    );
  }
}
