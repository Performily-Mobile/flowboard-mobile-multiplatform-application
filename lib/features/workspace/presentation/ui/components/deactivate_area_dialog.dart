import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/glass_dialog.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/features/workspace/domain/entity/area.dart';

/// Dialog to confirm the deactivation of an area, or to explain why it cannot be deactivated.
class DeactivateAreaDialog extends StatelessWidget {
  /// Creates the dialog.
  const DeactivateAreaDialog({
    super.key,
    required this.area,
    required this.confirmed,
    required this.isSaving,
    required this.errorMessage,
    required this.onConfirmedChange,
    required this.onConfirm,
    required this.onDismiss,
  });

  final Area area;
  final bool confirmed;
  final bool isSaving;
  final String? errorMessage;
  final ValueChanged<bool> onConfirmedChange;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool canDeactivate = area.canBeDeactivated;

    return GlassDialog(
      icon: Icon(FlowboardIcons.warning, color: scheme.error),
      title: 'Desactivar el área ${area.name}',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: <Widget>[
          Text(
            canDeactivate
                ? 'Esta acción no se puede deshacer desde la aplicación. El área dejará de aparecer al crear '
                    'o editar posiciones. No tiene colaboradores activos, así que nadie queda sin área.'
                : 'El área tiene ${area.activeEmployees} colaboradores activos. Reasígnalos a otra área '
                    'antes de desactivarla.',
            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          if (canDeactivate)
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onConfirmedChange(!confirmed),
              child: Row(
                children: <Widget>[
                  Checkbox(value: confirmed, onChanged: (bool? value) => onConfirmedChange(value ?? false)),
                  Expanded(
                    child: Text(
                      'Entiendo el efecto de esta acción y quiero continuar.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          if (errorMessage != null)
            Text(errorMessage!, style: theme.textTheme.bodySmall?.copyWith(color: scheme.error)),
        ],
      ),
      actions: <Widget>[
        TextButton(onPressed: onDismiss, child: Text(canDeactivate ? 'Cancelar' : 'Cerrar')),
        if (canDeactivate)
          FilledButton(
            onPressed: confirmed && !isSaving ? onConfirm : null,
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
              minimumSize: const Size(64, 48),
            ),
            child: const Text('Desactivar área'),
          ),
      ],
    );
  }
}
