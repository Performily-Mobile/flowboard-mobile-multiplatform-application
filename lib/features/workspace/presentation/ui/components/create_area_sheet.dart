import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_sheet_header.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/features/workspace/presentation/state/organization_ui_state.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/personal_data_step.dart';

/// Content of the bottom sheet to create a new area.
class CreateAreaSheet extends StatelessWidget {
  /// Creates the content.
  const CreateAreaSheet({
    super.key,
    required this.form,
    required this.isSaving,
    required this.onNameChange,
    required this.onDescriptionChange,
    required this.onSave,
    required this.onDismiss,
  });

  final AreaForm form;
  final bool isSaving;
  final ValueChanged<String> onNameChange;
  final ValueChanged<String> onDescriptionChange;
  final VoidCallback onSave;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return SheetBody(
      children: <Widget>[
        const SheetHeader(title: 'Nueva área'),
        FormTextField(
          label: 'Nombre del área',
          value: form.name,
          onValueChange: onNameChange,
          error: form.nameError,
          textCapitalization: TextCapitalization.sentences,
        ),
        FormTextField(
          label: 'Descripción (opcional)',
          value: form.description,
          onValueChange: onDescriptionChange,
          minLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
        SheetActions(
          confirmLabel: 'Crear área',
          enabled: !isSaving && form.name.trim().isNotEmpty,
          isSaving: isSaving,
          onConfirm: onSave,
          onCancel: onDismiss,
        ),
      ],
    );
  }
}

/// Scrollable column with the margins of every bottom sheet of the workspace feature.
class SheetBody extends StatelessWidget {
  /// Creates the body with its [children].
  const SheetBody({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        0,
        AppSpacing.screenHorizontal,
        AppSpacing.xl,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: AppSpacing.m, children: children),
    );
  }
}

/// Title of a bottom sheet of the workspace feature, with an optional subtitle.
class SheetHeader extends StatelessWidget {
  /// Creates the header.
  const SheetHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => FlowboardSheetHeader(title: title, subtitle: subtitle);
}

/// Cancel and confirm buttons at the end of a bottom sheet, sharing the width.
///
/// While [isSaving] the confirm button shows a progress indicator.
class SheetActions extends StatelessWidget {
  /// Creates the buttons.
  const SheetActions({
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
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              child: const Text('Cancelar'),
            ),
          ),
          Expanded(
            child: FilledButton(
              onPressed: enabled ? onConfirm : null,
              child: isSaving ? const ButtonProgress() : Text(confirmLabel),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small progress indicator shown inside a button while its action runs.
class ButtonProgress extends StatelessWidget {
  /// Creates the indicator.
  const ButtonProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
  }
}
