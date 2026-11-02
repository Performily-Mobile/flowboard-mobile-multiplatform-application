import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/employee_avatar.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/status_chip.dart';

/// Glass card of the employee list with avatar, name, job and status.
class EmployeeListItem extends StatelessWidget {
  /// Creates the card.
  const EmployeeListItem({super.key, required this.employee, required this.onClick});

  final Employee employee;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GlassCard(
      onTap: onClick,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        spacing: AppSpacing.m,
        children: <Widget>[
          EmployeeAvatar(initials: employee.name.initials),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: <Widget>[
                Text(
                  employee.name.sortableName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
                ),
                Text(
                  employee.jobDescription,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          StatusChip(status: employee.status),
        ],
      ),
    );
  }
}
