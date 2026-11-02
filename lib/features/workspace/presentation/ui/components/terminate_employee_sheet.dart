import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/glass_dialog.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/features/workspace/presentation/state/employee_detail_ui_state.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/create_area_sheet.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/date_picker_field.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/select_field.dart';

/// Termination reasons offered by the form; the backend receives the text itself.
const List<String> terminationReasons = <String>[
  'Renuncia voluntaria',
  'Término de contrato',
  'Despido',
  'Mutuo acuerdo',
  'Jubilación',
];

/// Dialog to register the termination of an employee.
class TerminateEmployeeSheet extends StatelessWidget {
  /// Creates the dialog.
  const TerminateEmployeeSheet({
    super.key,
    required this.employeeName,
    required this.form,
    required this.isSaving,
    required this.errorMessage,
    required this.onReasonChange,
    required this.onDateChange,
    required this.onConfirm,
    required this.onDismiss,
  });

  final String employeeName;
  final TerminationForm form;
  final bool isSaving;
  final String? errorMessage;
  final ValueChanged<String> onReasonChange;
  final ValueChanged<DateTime> onDateChange;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return GlassDialog(
      title: 'Registrar cese',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.m,
        children: <Widget>[
          Text(
            '$employeeName pasará a estado Cesado y su acceso a Flowboard se inhabilitará de inmediato.',
            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          DatePickerField(
            label: 'Fecha de cese',
            value: form.terminationDate,
            onValueChange: onDateChange,
            isError: form.dateError != null,
            supportingText: form.dateError,
          ),
          SelectField<String>(
            label: 'Motivo',
            options: terminationReasons,
            selected: form.reason,
            optionLabel: (String reason) => reason,
            onSelect: onReasonChange,
            isError: form.reasonError != null,
            supportingText: form.reasonError,
          ),
          if (errorMessage != null)
            Text(errorMessage!, style: theme.textTheme.bodySmall?.copyWith(color: scheme.error)),
        ],
      ),
      actions: <Widget>[
        TextButton(onPressed: onDismiss, child: const Text('Cancelar')),
        FilledButton(
          onPressed: isSaving ? null : onConfirm,
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
            minimumSize: const Size(64, 48),
          ),
          child: isSaving ? const ButtonProgress() : const Text('Registrar cese'),
        ),
      ],
    );
  }
}
