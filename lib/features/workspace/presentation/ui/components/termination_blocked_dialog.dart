import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/glass_dialog.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/employee_avatar.dart';

/// Dialog that explains why a termination cannot be registered: the employee still has reports.
class TerminationBlockedDialog extends StatelessWidget {
  /// Creates the dialog.
  const TerminationBlockedDialog({
    super.key,
    required this.employeeName,
    required this.subordinates,
    required this.onSubordinateClick,
    required this.onReassignReports,
    required this.onDismiss,
  });

  final String employeeName;
  final List<Employee> subordinates;
  final ValueChanged<Employee> onSubordinateClick;
  final VoidCallback onReassignReports;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final int count = subordinates.length;
    return GlassDialog(
      icon: Icon(FlowboardIcons.warning, color: scheme.error),
      title: 'No se puede registrar el cese',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: <Widget>[
          Text(
            '$employeeName tiene $count ${count == 1 ? 'colaborador' : 'colaboradores'} a cargo. '
            'Asígnales otro jefe directo antes de registrar el cese.',
            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          for (final Employee subordinate in subordinates)
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onSubordinateClick(subordinate),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  spacing: 12,
                  children: <Widget>[
                    EmployeeAvatar(initials: subordinate.name.initials, size: 32),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(subordinate.name.fullName, style: theme.textTheme.bodyLarge),
                          Text(
                            subordinate.positionTitle,
                            style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      actions: <Widget>[
        TextButton(onPressed: onDismiss, child: const Text('Cerrar')),
        FilledButton(
          onPressed: onReassignReports,
          style: FilledButton.styleFrom(minimumSize: const Size(64, 48)),
          child: const Text('Reasignar reportes'),
        ),
      ],
    );
  }
}
