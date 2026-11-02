import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/detail_row.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/workspace_labels.dart';

/// "Datos" tab of the employee record: identity and contact data grouped in one panel.
class PersonalDataTab extends StatelessWidget {
  /// Creates the tab.
  const PersonalDataTab({super.key, required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DateTime? updatedAt = employee.updatedAt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.s,
      children: <Widget>[
        InfoPanel(
          children: <Widget>[
            DetailRow(
              label: 'Documento de identidad',
              value: '${employee.identityDocument.type.label} ${employee.identityDocument.number}',
            ),
            DetailRow(label: 'Fecha de nacimiento', value: formatDisplayDate(employee.birthDate.value)),
            DetailRow(label: 'Correo corporativo', value: employee.email.value),
            DetailRow(label: 'Teléfono', value: employee.phoneNumber.value),
            DetailRow(label: 'Dirección', value: employee.address.formatted),
          ],
        ),
        if (updatedAt != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Última modificación: ${formatDisplayDate(updatedAt)}',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
      ],
    );
  }
}
