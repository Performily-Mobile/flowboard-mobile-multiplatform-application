import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_area_summary.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_employee.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_employee_hours.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_totals.dart';
import 'package:flowboard/features/attendance/domain/valueobject/punch_type.dart';
import 'package:flowboard/features/attendance/presentation/ui/components/attendance_colors.dart';
import 'package:flowboard/features/attendance/presentation/ui/components/attendance_common.dart';
import 'package:flowboard/features/attendance/presentation/ui/components/attendance_formatters.dart';
import 'package:flowboard/features/attendance/presentation/ui/components/attendance_labels.dart';

const EdgeInsets _cardPadding = EdgeInsets.all(AppSpacing.l);

/// Card of one attendance record: day, punches, hours and status.
class AttendanceRecordCard extends StatelessWidget {
  /// Creates the card; [showEmployee] adds the name of the employee for the HR lists.
  const AttendanceRecordCard({super.key, required this.record, this.showEmployee = false, this.onTap});

  final AttendanceRecord record;
  final bool showEmployee;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;
    final String? reason = record.justificationReason;
    return GlassCard(
      onTap: onTap,
      padding: _cardPadding,
      child: Row(
        spacing: AppSpacing.m,
        children: <Widget>[
          if (showEmployee) AttendanceAvatar(name: record.displayName),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: <Widget>[
                if (showEmployee)
                  Text(
                    AttendanceFormatters.shortName(record.displayName),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                  ),
                Text(
                  AttendanceFormatters.day(record.workDate),
                  style: showEmployee
                      ? theme.textTheme.bodyMedium?.copyWith(color: muted)
                      : theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  AttendanceFormatters.punches(record),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
                if (reason != null && reason.trim().isNotEmpty)
                  Text(
                    reason,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
          AttendanceStatusChip(status: record.status),
        ],
      ),
    );
  }
}

/// Card of today: the punches already made and the button for the next one.
class AttendanceTodayCard extends StatelessWidget {
  /// Creates the card; [nextPunch] null means the work day is closed.
  const AttendanceTodayCard({
    super.key,
    required this.today,
    required this.record,
    required this.nextPunch,
    required this.isPunching,
    required this.onPunch,
  });

  final DateTime today;

  /// Record of today; null when the employee has not punched yet.
  final AttendanceRecord? record;
  final PunchType? nextPunch;
  final bool isPunching;
  final VoidCallback onPunch;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;
    final DateTime? checkIn = record?.checkIn;
    final DateTime? checkOut = record?.checkOut;
    final PunchType? punch = nextPunch;
    return GlassCard(
      strong: true,
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.m,
        children: <Widget>[
          Row(
            spacing: AppSpacing.m,
            children: <Widget>[
              const AttendanceIconCircle(icon: FlowboardIcons.schedule),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: <Widget>[
                    Text('Hoy', style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                    Text(
                      AttendanceFormatters.longDay(today),
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              if (record != null) AttendanceStatusChip(status: record!.status),
            ],
          ),
          Row(
            spacing: AppSpacing.m,
            children: <Widget>[
              Expanded(child: _PunchValue(label: 'Entrada', time: checkIn)),
              Expanded(child: _PunchValue(label: 'Salida', time: checkOut)),
            ],
          ),
          if (punch == null)
            const AttendanceBanner(
              message: 'Ya registraste tu entrada y tu salida de hoy.',
              icon: FlowboardIcons.check,
              containerColor: AttendanceColors.dayClosed,
            )
          else
            FilledButton.icon(
              onPressed: isPunching ? null : onPunch,
              icon: isPunching ? const AttendanceButtonProgress() : const Icon(FlowboardIcons.schedule),
              label: Text(punch.actionLabel),
            ),
        ],
      ),
    );
  }
}

/// Label and time of one punch of today, or a dash when it is missing.
class _PunchValue extends StatelessWidget {
  const _PunchValue({required this.label, required this.time});

  final String label;
  final DateTime? time;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DateTime? value = time;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: <Widget>[
        Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        Text(value == null ? '--:--' : AttendanceFormatters.time(value), style: theme.textTheme.titleLarge),
      ],
    );
  }
}

/// Label and value of one tile of an [AttendanceMetricGrid].
class AttendanceMetric {
  /// Creates the metric.
  const AttendanceMetric(this.label, this.value);

  final String label;
  final String value;
}

/// Grid of small tiles with a label and a big value, two per row.
class AttendanceMetricGrid extends StatelessWidget {
  /// Creates the grid with [metrics].
  const AttendanceMetricGrid({super.key, required this.metrics});

  /// Grid of the totals of a list of records.
  factory AttendanceMetricGrid.totals(AttendanceTotals totals, {Key? key}) {
    return AttendanceMetricGrid(
      key: key,
      metrics: <AttendanceMetric>[
        AttendanceMetric('Puntualidad', AttendanceFormatters.percent(totals.punctualityPercentage)),
        AttendanceMetric('Tardanzas', '${totals.late}'),
        AttendanceMetric('Faltas', '${totals.absent}'),
        AttendanceMetric('Horas trabajadas', AttendanceFormatters.hours(totals.workedHours)),
      ],
    );
  }

  /// Grid of the totals of an area.
  factory AttendanceMetricGrid.area(AttendanceAreaSummary summary, {Key? key}) {
    return AttendanceMetricGrid(
      key: key,
      metrics: <AttendanceMetric>[
        AttendanceMetric('Puntualidad', AttendanceFormatters.percent(summary.punctualityPercentage)),
        AttendanceMetric('Tardanzas', '${summary.late}'),
        AttendanceMetric('Faltas', '${summary.absent}'),
        AttendanceMetric('Justificadas', '${summary.justified}'),
        AttendanceMetric('Horas trabajadas', AttendanceFormatters.hours(summary.workedHours)),
        AttendanceMetric('Sobretiempo', AttendanceFormatters.hours(summary.overtimeHours)),
      ],
    );
  }

  final List<AttendanceMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: AppSpacing.s,
      children: <Widget>[
        for (int start = 0; start < metrics.length; start += 2)
          Row(
            spacing: AppSpacing.s,
            children: <Widget>[
              Expanded(child: _MetricTile(metric: metrics[start])),
              Expanded(
                child: start + 1 < metrics.length ? _MetricTile(metric: metrics[start + 1]) : const SizedBox.shrink(),
              ),
            ],
          ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.metric});

  final AttendanceMetric metric;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: AppSpacing.l),
      semanticLabel: '${metric.label}: ${metric.value}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.xs,
        children: <Widget>[
          Text(
            metric.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          Text(metric.value, maxLines: 1, style: theme.textTheme.titleLarge),
        ],
      ),
    );
  }
}

/// Row of an employee of an area with their punctuality and absences in the period.
class AttendanceEmployeeRow extends StatelessWidget {
  /// Creates the row.
  const AttendanceEmployeeRow({super.key, required this.employee, required this.totals, required this.onTap});

  final AttendanceEmployee employee;
  final AttendanceTotals totals;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;
    final String detail = totals.total == 0
        ? 'Sin registros en el periodo'
        : '${AttendanceFormatters.percent(totals.punctualityPercentage)} puntual · '
            '${totals.late} tardanzas · ${totals.absent} faltas';
    return GlassCard(
      onTap: onTap,
      padding: _cardPadding,
      child: Row(
        spacing: AppSpacing.m,
        children: <Widget>[
          AttendanceAvatar(name: employee.name),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: <Widget>[
                Text(
                  AttendanceFormatters.shortName(employee.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  employee.positionTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                ),
                Text(detail, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
              ],
            ),
          ),
          Icon(FlowboardIcons.chevronRight, color: muted),
        ],
      ),
    );
  }
}

/// Row of the hours report: employee, worked hours and overtime.
class AttendanceHoursRow extends StatelessWidget {
  /// Creates the row.
  const AttendanceHoursRow({super.key, required this.row, this.onTap});

  final AttendanceEmployeeHours row;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;
    final double overtime = row.hours.overtimeHours;
    return GlassCard(
      onTap: onTap,
      padding: _cardPadding,
      child: Row(
        spacing: AppSpacing.m,
        children: <Widget>[
          AttendanceAvatar(name: row.employee.name),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: <Widget>[
                Text(
                  AttendanceFormatters.shortName(row.employee.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  row.employee.positionTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 2,
            children: <Widget>[
              Text(AttendanceFormatters.hours(row.hours.workedHours), style: theme.textTheme.titleMedium),
              Text(
                overtime > 0 ? '+${AttendanceFormatters.hours(overtime)} extra' : 'Sin sobretiempo',
                style: theme.textTheme.bodySmall?.copyWith(color: overtime > 0 ? theme.colorScheme.primary : muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
