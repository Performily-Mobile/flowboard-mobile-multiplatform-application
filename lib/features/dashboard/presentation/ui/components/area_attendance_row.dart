import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/theme/app_glass.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/features/dashboard/domain/entity/hr_dashboard.dart';
import 'package:flowboard/features/dashboard/presentation/ui/components/dashboard_accent.dart';

/// Row with the area name, a progress bar colored by how healthy the attendance is, and the percentage.
class AreaAttendanceRow extends StatelessWidget {
  /// Creates the row.
  const AreaAttendanceRow({super.key, required this.attendance});

  final AreaAttendance attendance;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final GlassTokens tokens = GlassTokens.of(context);

    return Semantics(
      label: '${attendance.areaName}, ${attendance.percentage}% de asistencia',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
        child: Row(
          spacing: AppSpacing.m,
          children: <Widget>[
            SizedBox(
              width: 104,
              child: Text(
                attendance.areaName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Expanded(
              child: LinearProgressIndicator(
                value: attendance.percentage / 100,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
                color: DashboardColors.attendanceBar(attendance.percentage),
                backgroundColor: tokens.track,
              ),
            ),
            SizedBox(
              width: 44,
              child: Text(
                '${attendance.percentage}%',
                textAlign: TextAlign.end,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
