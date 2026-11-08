import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_sheet_header.dart';
import 'package:flowboard/core/designsystem/component/glass_dialog.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/features/payroll/domain/valueobject/payment_details.dart';
import 'package:flowboard/features/payroll/domain/valueobject/payment_status.dart';
import 'package:flowboard/features/payroll/presentation/state/payment_sheet_form.dart';
import 'package:flowboard/features/payroll/presentation/state/upload_payslips_ui_state.dart';
import 'package:flowboard/features/payroll/presentation/ui/components/payroll_common.dart';
import 'package:flowboard/features/payroll/presentation/ui/components/payroll_fields.dart';

/// "Ya existe una boleta" (MA-68): HR decides whether the new file replaces the uploaded one.
class DuplicatePayslipDialog extends StatelessWidget {
  /// Creates the dialog.
  const DuplicatePayslipDialog({
    super.key,
    required this.prompt,
    required this.onReplace,
    required this.onCancel,
  });

  final DuplicatePrompt prompt;
  final VoidCallback onReplace;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GlassDialog(
      icon: Icon(FlowboardIcons.warning, color: theme.colorScheme.primary),
      title: 'Ya existe una boleta',
      content: Text(
        '${prompt.employeeName} ya tiene una boleta cargada para ${prompt.periodLabel}. '
        '¿Deseas reemplazarla por el archivo nuevo?',
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
      actions: <Widget>[
        TextButton(onPressed: onCancel, child: const Text('Cancelar')),
        TextButton(onPressed: onReplace, child: const Text('Reemplazar')),
      ],
    );
  }
}

/// "Actualizar estado de pago" (MA-69): registers the deposit as paid or observed.
class UpdatePaymentStatusSheet extends StatelessWidget {
  /// Creates the sheet content.
  const UpdatePaymentStatusSheet({
    super.key,
    required this.form,
    required this.onChoiceChange,
    required this.onPaidOnChange,
    required this.onReasonChange,
    required this.onSave,
    required this.onDismiss,
  });

  final PaymentSheetForm form;
  final ValueChanged<PaymentStatus> onChoiceChange;
  final ValueChanged<DateTime> onPaidOnChange;
  final ValueChanged<String> onReasonChange;
  final VoidCallback onSave;
  final VoidCallback onDismiss;

  static const List<PaymentStatus> _choices = <PaymentStatus>[PaymentStatus.paid, PaymentStatus.observed];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DateTime now = DateTime.now();
    final PaymentStatus? choice = form.choice;
    final String? error = form.error;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.l,
        children: <Widget>[
          FlowboardSheetHeader(title: 'Actualizar estado de pago', subtitle: form.subtitle),
          SegmentedButton<PaymentStatus>(
            segments: <ButtonSegment<PaymentStatus>>[
              for (final PaymentStatus option in _choices)
                ButtonSegment<PaymentStatus>(value: option, label: Text(option.label)),
            ],
            selected: <PaymentStatus>{?choice},
            emptySelectionAllowed: true,
            showSelectedIcon: true,
            onSelectionChanged: form.isSaving
                ? null
                : (Set<PaymentStatus> selection) {
                    if (selection.isNotEmpty) onChoiceChange(selection.first);
                  },
          ),
          if (choice == PaymentStatus.observed)
            PayrollTextField(
              label: 'Motivo de la observación',
              value: form.reason,
              onValueChange: onReasonChange,
              maxLength: PaymentDetails.reasonMaxLength,
            ),
          if (choice == PaymentStatus.paid)
            PayrollDateField(
              label: 'Fecha de depósito',
              value: form.paidOn,
              onValueChange: onPaidOnChange,
              lastDate: DateTime(now.year, now.month, now.day),
            ),
          if (error != null) Text(error, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: AppSpacing.s,
            children: <Widget>[
              TextButton(onPressed: form.isSaving ? null : onDismiss, child: const Text('Cancelar')),
              FilledButton(
                onPressed: form.canSave ? onSave : null,
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                child: form.isSaving ? const PayrollButtonProgress() : const Text('Guardar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
