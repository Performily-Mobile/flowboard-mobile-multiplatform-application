import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_sheet_header.dart';
import 'package:flowboard/core/designsystem/component/glass_dialog.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/features/request/domain/valueobject/field_data_type.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_common.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_fields.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_labels.dart';

const int _maxComment = 500;

/// Confirmation shown before the viewer cancels one of their requests.
class CancelRequestDialog extends StatelessWidget {
  /// Creates the dialog.
  const CancelRequestDialog({
    super.key,
    required this.message,
    required this.isCancelling,
    required this.onConfirm,
    required this.onDismiss,
  });

  final String message;
  final bool isCancelling;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return GlassDialog(
      icon: Icon(FlowboardIcons.warning, color: scheme.error),
      title: '¿Cancelar la solicitud?',
      content: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
      actions: <Widget>[
        TextButton(onPressed: isCancelling ? null : onDismiss, child: const Text('Volver')),
        FilledButton(
          onPressed: isCancelling ? null : onConfirm,
          style: FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError),
          child: isCancelling ? const RequestButtonProgress() : const Text('Cancelar solicitud'),
        ),
      ],
    );
  }
}

/// Dialog that asks for the reason before rejecting a request.
class RejectRequestDialog extends StatelessWidget {
  /// Creates the dialog.
  const RejectRequestDialog({
    super.key,
    required this.requesterName,
    required this.reason,
    required this.error,
    required this.isSaving,
    required this.onReasonChange,
    required this.onConfirm,
    required this.onDismiss,
  });

  final String requesterName;
  final String reason;
  final String? error;
  final bool isSaving;
  final ValueChanged<String> onReasonChange;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GlassDialog(
      title: 'Rechazar solicitud',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.l,
        children: <Widget>[
          Text(
            '$requesterName verá el motivo en el detalle de su solicitud y recibirá una notificación.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          RequestTextField(
            label: 'Motivo del rechazo',
            value: reason,
            onValueChange: onReasonChange,
            error: error,
            maxLength: _maxComment,
            minLines: 3,
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(onPressed: isSaving ? null : onDismiss, child: const Text('Cancelar')),
        FilledButton(
          onPressed: isSaving ? null : onConfirm,
          child: isSaving ? const RequestButtonProgress() : const Text('Rechazar'),
        ),
      ],
    );
  }
}

/// Content of the bottom sheet that asks for a comment before returning a request for review.
class ReturnForReviewSheet extends StatelessWidget {
  /// Creates the content.
  const ReturnForReviewSheet({
    super.key,
    required this.requesterFirstName,
    required this.comment,
    required this.error,
    required this.isSaving,
    required this.onCommentChange,
    required this.onConfirm,
    required this.onDismiss,
  });

  final String requesterFirstName;
  final String comment;
  final String? error;
  final bool isSaving;
  final ValueChanged<String> onCommentChange;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return RequestSheetBody(
      children: <Widget>[
        FlowboardSheetHeader(
          title: 'Devolver a revisión',
          subtitle: 'La solicitud pasará a "En revisión" y volverá a tu bandeja cuando $requesterFirstName '
              'la reenvíe.',
        ),
        RequestTextField(
          label: 'Comentario para el colaborador',
          value: comment,
          onValueChange: onCommentChange,
          error: error,
          maxLength: _maxComment,
          minLines: 3,
        ),
        RequestSheetActions(
          confirmLabel: 'Devolver',
          isSaving: isSaving,
          onConfirm: onConfirm,
          onCancel: onDismiss,
        ),
      ],
    );
  }
}

/// Confirmation shown before deleting a request type.
class DeleteRequestTypeDialog extends StatelessWidget {
  /// Creates the dialog.
  const DeleteRequestTypeDialog({
    super.key,
    required this.typeName,
    required this.isDeleting,
    required this.onConfirm,
    required this.onDismiss,
  });

  final String typeName;
  final bool isDeleting;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return GlassDialog(
      icon: Icon(FlowboardIcons.warning, color: scheme.error),
      title: '¿Eliminar $typeName?',
      content: Text(
        'Solo se puede eliminar si nadie lo ha usado. Si ya tiene solicitudes, podrás desactivarlo.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),
      actions: <Widget>[
        TextButton(onPressed: isDeleting ? null : onDismiss, child: const Text('Cancelar')),
        FilledButton(
          onPressed: isDeleting ? null : onConfirm,
          style: FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError),
          child: isDeleting ? const RequestButtonProgress() : const Text('Eliminar'),
        ),
      ],
    );
  }
}

/// Content of the bottom sheet to add a field to a new request type.
class AddFieldSheet extends StatelessWidget {
  /// Creates the content.
  const AddFieldSheet({
    super.key,
    required this.label,
    required this.dataType,
    required this.isRequired,
    required this.error,
    required this.onLabelChange,
    required this.onDataTypeChange,
    required this.onRequiredChange,
    required this.onAdd,
    required this.onDismiss,
  });

  final String label;
  final FieldDataType dataType;
  final bool isRequired;
  final String? error;
  final ValueChanged<String> onLabelChange;
  final ValueChanged<FieldDataType> onDataTypeChange;
  final ValueChanged<bool> onRequiredChange;
  final VoidCallback onAdd;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return RequestSheetBody(
      children: <Widget>[
        const FlowboardSheetHeader(title: 'Agregar campo'),
        RequestTextField(label: 'Nombre del campo', value: label, onValueChange: onLabelChange, error: error),
        RequestSelectField<FieldDataType>(
          label: 'Tipo de dato',
          options: FieldDataType.values,
          selected: dataType,
          optionLabel: (FieldDataType type) => type.label,
          onSelect: onDataTypeChange,
        ),
        RequestSwitchRow(title: 'Obligatorio', value: isRequired, onChanged: onRequiredChange),
        RequestSheetActions(confirmLabel: 'Agregar', isSaving: false, onConfirm: onAdd, onCancel: onDismiss),
      ],
    );
  }
}

/// Scrollable column with the margins of every bottom sheet of the request feature.
class RequestSheetBody extends StatelessWidget {
  /// Creates the body with its [children].
  const RequestSheetBody({super.key, required this.children});

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
class RequestSheetActions extends StatelessWidget {
  /// Creates the buttons; while [isSaving] the confirm button shows a progress indicator.
  const RequestSheetActions({
    super.key,
    required this.confirmLabel,
    required this.isSaving,
    required this.onConfirm,
    required this.onCancel,
  });

  final String confirmLabel;
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
              onPressed: isSaving ? null : onConfirm,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              child: isSaving ? const RequestButtonProgress() : Text(confirmLabel),
            ),
          ),
        ],
      ),
    );
  }
}
