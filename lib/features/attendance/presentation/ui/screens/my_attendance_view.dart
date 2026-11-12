import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/collapsing_header_layout.dart';
import 'package:flowboard/core/designsystem/component/skeleton.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/presentation/state/attendance_filters.dart';
import 'package:flowboard/features/attendance/presentation/state/my_attendance_ui_state.dart';
import 'package:flowboard/features/attendance/presentation/ui/components/attendance_cards.dart';
import 'package:flowboard/features/attendance/presentation/ui/components/attendance_common.dart';
import 'package:flowboard/features/attendance/presentation/ui/components/attendance_fields.dart';
import 'package:flowboard/features/attendance/presentation/ui/navigation/attendance_navigation.dart';
import 'package:flowboard/features/attendance/presentation/viewmodel/my_attendance_view_model.dart';

/// Attendance of the signed-in employee: today's punch, the totals and the records of a period.
///
/// The period and the status filter live in a header that slides away while the list scrolls. The
/// days that can be justified open the justification form.
class MyAttendanceView extends StatefulWidget {
  /// Creates the view.
  const MyAttendanceView({super.key});

  @override
  State<MyAttendanceView> createState() => _MyAttendanceViewState();
}

class _MyAttendanceViewState extends State<MyAttendanceView> {
  late final MyAttendanceViewModel _viewModel = getIt<MyAttendanceViewModel>();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onStateChanged);
    _viewModel.load();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onStateChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (!mounted) return;
    final String? message = _viewModel.state.snackbarMessage;
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      scheduleMicrotask(_viewModel.consumeMessage);
    }
  }

  Future<void> _openJustify(AttendanceRecord record) async {
    final Object? result =
        await Navigator.of(context, rootNavigator: true).pushNamed(AttendanceRoutes.justify, arguments: record);
    if (mounted && result is String) _viewModel.onResult(result);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        final MyAttendanceUiState state = _viewModel.state;
        return CollapsingHeaderLayout(
          showHeaderKey: Object.hash(state.records.length, state.isLoading, state.errorMessage != null),
          header: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: AppSpacing.m),
            child: AttendanceChipRow(
              children: <Widget>[
                AttendancePeriodChip(period: state.period, onSelect: _viewModel.onPeriodSelected),
                AttendanceMenuChip<AttendanceStatusFilter>(
                  label: 'Estado: ${state.statusFilter.label.toLowerCase()}',
                  selected: state.statusFilter != AttendanceStatusFilter.all,
                  options: AttendanceStatusFilter.values,
                  optionLabel: (AttendanceStatusFilter filter) => filter.label,
                  onSelect: _viewModel.onStatusFilterSelected,
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

  Widget _buildContent(BuildContext context, MyAttendanceUiState state, double headerHeight) {
    final EdgeInsets padding = EdgeInsets.fromLTRB(
      AppSpacing.screenHorizontal,
      headerHeight + 8,
      AppSpacing.screenHorizontal,
      AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
    );
    if (state.isLoading && state.attendance == null) {
      return SkeletonList(padding: padding, showAvatar: false);
    }
    final String? errorMessage = state.errorMessage;
    if (errorMessage != null && state.attendance == null) {
      return ListView(
        padding: padding,
        children: <Widget>[
          AttendanceMessageState(
            title: 'No se pudo cargar tu asistencia',
            message: errorMessage,
            actionLabel: 'Reintentar',
            onAction: _viewModel.load,
          ),
        ],
      );
    }
    final List<AttendanceRecord> records = state.records;
    final bool canJustify = records.any((AttendanceRecord record) => record.canBeJustified);
    return RefreshIndicator(
      onRefresh: _viewModel.load,
      edgeOffset: headerHeight,
      child: ListView(
        padding: padding,
        children: <Widget>[
          AttendanceTodayCard(
            today: DateTime.now(),
            record: state.today,
            nextPunch: state.nextPunch,
            isPunching: state.isPunching,
            onPunch: _viewModel.punch,
          ),
          const SizedBox(height: AppSpacing.l),
          AttendanceMetricGrid.totals(state.totals),
          const SizedBox(height: AppSpacing.l),
          const AttendanceSectionHeader(text: 'Registros del periodo'),
          const SizedBox(height: AppSpacing.m),
          if (canJustify) ...<Widget>[
            const AttendanceBanner(
              message: 'Toca un día con tardanza, falta o marcación incompleta para justificarlo.',
              icon: FlowboardIcons.info,
            ),
            const SizedBox(height: AppSpacing.m),
          ],
          if (records.isEmpty)
            AttendanceMessageState(
              title: state.statusFilter == AttendanceStatusFilter.all
                  ? 'No hay registros en este periodo'
                  : 'No hay registros con este estado',
              message: state.statusFilter == AttendanceStatusFilter.all
                  ? 'Tus marcaciones aparecerán aquí.'
                  : 'Prueba con otro filtro.',
            )
          else
            for (final AttendanceRecord record in records)
              Padding(
                key: ValueKey<String>('${record.id}-${record.workDate}'),
                padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
                child: AttendanceRecordCard(
                  record: record,
                  onTap: record.canBeJustified ? () => _openJustify(record) : null,
                ),
              ),
        ],
      ),
    );
  }
}
