import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_sheet_header.dart';
import 'package:flowboard/core/designsystem/component/glass_dialog.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/features/benefits/domain/entity/benefit_assignment.dart';
import 'package:flowboard/features/benefits/domain/entity/benefit_type.dart';
import 'package:flowboard/features/benefits/domain/valueobject/adjustment_operation.dart';
import 'package:flowboard/features/benefits/domain/valueobject/benefit_unit.dart';
import 'package:flowboard/features/benefits/presentation/state/benefits_admin_ui_state.dart';
import 'package:flowboard/features/benefits/presentation/state/vacation_balance_detail_ui_state.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_common.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_fields.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_formatters.dart';

/// Content of the "Nuevo tipo de beneficio" sheet (MA-60): name, unit and whether it tracks a balance.
class CreateBenefitTypeSheet extends StatelessWidget {
  /// Creates the content.
  const CreateBenefitTypeSheet({
    super.key,
    required this.form,
    required this.onNameChange,
    required this.onUnitChange,
    required this.onHasBalanceChange,
    required this.onCreate,
    required this.onDismiss,
  });

  final BenefitTypeForm form;
  final ValueChanged<String> onNameChange;
  final ValueChanged<BenefitUnit> onUnitChange;
  final ValueChanged<bool> onHasBalanceChange;
  final VoidCallback onCreate;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return BenefitsSheetBody(
      children: <Widget>[
        const FlowboardSheetHeader(title: 'Nuevo tipo de beneficio'),
        BenefitsTextField(label: 'Nombre', value: form.name, onValueChange: onNameChange, error: form.nameError),
        BenefitsSelectField<BenefitUnit>(
          label: 'Unidad de medida',
          options: BenefitUnit.values,
          selected: form.unit,
          optionLabel: (BenefitUnit unit) => unit.label,
          onSelect: onUnitChange,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Maneja saldo'),
          value: form.hasBalance,
          onChanged: form.isSaving ? null : onHasBalanceChange,
        ),
        BenefitsSheetActions(
          confirmLabel: 'Crear',
          enabled: !form.isSaving && form.name.trim().isNotEmpty,
          isSaving: form.isSaving,
          onConfirm: onCreate,
          onCancel: onDismiss,
        ),
      ],
    );
  }
}

/// Confirmation to activate or deactivate a type of the catalog (MA-60).
class ToggleBenefitTypeDialog extends StatelessWidget {
  /// Creates the dialog.
  const ToggleBenefitTypeDialog({
    super.key,
    required this.benefitType,
    required this.isSaving,
    required this.onConfirm,
    required this.onDismiss,
  });

  final BenefitType benefitType;
  final bool isSaving;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool deactivate = benefitType.active;
    return GlassDialog(
      icon: Icon(deactivate ? FlowboardIcons.warning : FlowboardIcons.gift, color: theme.colorScheme.primary),
      title: deactivate ? '¿Desactivar ${benefitType.name}?' : '¿Activar ${benefitType.name}?',
      content: Text(
        deactivate
            ? 'Seguirá en el catálogo y en las asignaciones existentes, pero ya no se podrá asignar.'
            : 'Volverá a estar disponible para asignar.',
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
      actions: <Widget>[
        TextButton(onPressed: isSaving ? null : onDismiss, child: const Text('Cancelar')),
        FilledButton(
          onPressed: isSaving ? null : onConfirm,
          child: isSaving ? const BenefitsButtonProgress() : Text(deactivate ? 'Desactivar' : 'Activar'),
        ),
      ],
    );
  }
}

/// "Registrar entrega" dialog (MA-62). A delivery can be registered only once.
class RegisterDeliveryDialog extends StatelessWidget {
  /// Creates the dialog.
  const RegisterDeliveryDialog({
    super.key,
    required this.form,
    required this.onDateChange,
    required this.onNotesChange,
    required this.onConfirm,
    required this.onDismiss,
  });

  final DeliveryForm form;
  final ValueChanged<DateTime> onDateChange;
  final ValueChanged<String> onNotesChange;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final BenefitAssignment assignment = form.assignment;
    final DateTime now = DateTime.now();
    final String? error = form.error;
    return GlassDialog(
      title: 'Registrar entrega',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.l,
        children: <Widget>[
          Text(
            '${assignment.benefitTypeName} · ${BenefitsFormatters.quantity(assignment.quantity, assignment.unit)} '
            'para ${assignment.employeeName}. Una vez registrada no podrá registrarse otra vez.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          BenefitsDateField(
            label: 'Fecha de entrega',
            value: form.deliveredOn,
            onValueChange: onDateChange,
            firstDate: assignment.startDate,
            lastDate: DateTime(now.year, now.month, now.day),
          ),
          BenefitsTextField(label: 'Observaciones (opcional)', value: form.notes, onValueChange: onNotesChange),
          if (error != null) Text(error, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
        ],
      ),
      actions: <Widget>[
        TextButton(onPressed: form.isSaving ? null : onDismiss, child: const Text('Cancelar')),
        FilledButton(
          onPressed: form.isSaving ? null : onConfirm,
          child: form.isSaving ? const BenefitsButtonProgress() : const Text('Registrar'),
        ),
      ],
    );
  }
}

/// Content of the "Ajustar saldo" sheet (MA-63): adds or deducts days with a required reason.
class AdjustBalanceSheet extends StatelessWidget {
  /// Creates the content.
  const AdjustBalanceSheet({
    super.key,
    required this.form,
    required this.onOperationChange,
    required this.onDaysChange,
    required this.onReasonChange,
    required this.onSave,
    required this.onDismiss,
  });

  final AdjustmentForm form;
  final ValueChanged<AdjustmentOperation> onOperationChange;
  final ValueChanged<String> onDaysChange;
  final ValueChanged<String> onReasonChange;
  final VoidCallback onSave;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? error = form.errorMessage;
    return BenefitsSheetBody(
      children: <Widget>[
        const FlowboardSheetHeader(
          title: 'Ajustar saldo',
          subtitle: 'El ajuste quedará en el historial con tu nombre y el motivo.',
        ),
        BenefitsSegmented<AdjustmentOperation>(
          options: AdjustmentOperation.values,
          selected: form.operation,
          optionLabel: (AdjustmentOperation operation) => operation.label,
          onSelect: onOperationChange,
        ),
        BenefitsTextField(
          label: 'Cantidad de días',
          value: form.days,
          onValueChange: onDaysChange,
          error: form.daysError,
          numeric: true,
        ),
        BenefitsTextField(
          label: 'Motivo del ajuste',
          value: form.reason,
          onValueChange: onReasonChange,
          error: form.reasonError,
          minLines: 3,
        ),
        if (error != null) Text(error, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
        BenefitsSheetActions(
          confirmLabel: 'Guardar ajuste',
          enabled: !form.isSaving,
          isSaving: form.isSaving,
          onConfirm: onSave,
          onCancel: onDismiss,
        ),
      ],
    );
  }
}

/// Scrollable column with the margins of the Benefits bottom sheets.
class BenefitsSheetBody extends StatelessWidget {
  /// Creates the body with its [children].
  const BenefitsSheetBody({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 0, AppSpacing.screenHorizontal, AppSpacing.xl),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: AppSpacing.m, children: children),
    );
  }
}

/// Cancel and confirm buttons at the end of a bottom sheet, sharing the width.
class BenefitsSheetActions extends StatelessWidget {
  /// Creates the buttons.
  const BenefitsSheetActions({
    super.key,
    required this.confirmLabel,
    required this.enabled,
    required this.onConfirm,
    required this.onCancel,
    this.isSaving = false,
  });

  final String confirmLabel;
  final bool enabled;
  final bool isSaving;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s),
      child: Row(
        spacing: AppSpacing.m,
        children: <Widget>[
          Expanded(
            child: OutlinedButton(
              onPressed: isSaving ? null : onCancel,
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              child: const Text('Cancelar'),
            ),
          ),
          Expanded(
            child: FilledButton(
              onPressed: enabled ? onConfirm : null,
              child: isSaving ? const BenefitsButtonProgress() : Text(confirmLabel),
            ),
          ),
        ],
      ),
    );
  }
}
