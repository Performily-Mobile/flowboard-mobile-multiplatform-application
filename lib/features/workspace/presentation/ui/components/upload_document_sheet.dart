import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/features/workspace/domain/valueobject/document_type.dart';
import 'package:flowboard/features/workspace/presentation/state/employee_detail_ui_state.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/create_area_sheet.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/select_field.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/workspace_labels.dart';

/// Content of the bottom sheet to add a document (PDF, JPG or PNG) to an employee record.
class UploadDocumentSheet extends StatelessWidget {
  /// Creates the content.
  const UploadDocumentSheet({
    super.key,
    required this.form,
    required this.isSaving,
    required this.errorMessage,
    required this.onDocumentTypeChange,
    required this.onFileSelected,
    required this.onSave,
    required this.onDismiss,
  });

  final UploadDocumentForm form;
  final bool isSaving;
  final String? errorMessage;
  final ValueChanged<DocumentType> onDocumentTypeChange;
  final ValueChanged<SelectedFile> onFileSelected;
  final VoidCallback onSave;
  final VoidCallback onDismiss;

  Future<void> _pickFile() async {
    final PlatformFile? picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const <String>['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (picked == null) return;
    final int size = await picked.length() ?? 0;
    onFileSelected(
      SelectedFile(
        uri: picked.path ?? '',
        name: picked.name,
        contentType: _contentTypeOf(picked.extension),
        sizeInBytes: size,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final SelectedFile? file = form.file;
    final String hint = form.fileError ??
        (file == null ? 'PDF, JPG o PNG de hasta 5 MB.' : '${_formatLabel(file.contentType)} · ${_sizeLabel(file.sizeInBytes)}');

    return SheetBody(
      children: <Widget>[
        const SheetHeader(title: 'Subir documento'),
        SelectField<DocumentType>(
          label: 'Tipo de documento',
          options: DocumentType.values,
          selected: form.documentType,
          optionLabel: (DocumentType type) => type.label,
          onSelect: onDocumentTypeChange,
          isError: form.documentTypeError != null,
          supportingText: form.documentTypeError,
        ),
        OutlinedButton.icon(
          onPressed: _pickFile,
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          icon: const Icon(FlowboardIcons.attachFile),
          label: Text(file?.name ?? 'Seleccionar archivo', maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        Text(
          hint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: form.fileError != null ? scheme.error : scheme.onSurfaceVariant,
          ),
        ),
        if (errorMessage != null)
          Text(errorMessage!, style: theme.textTheme.bodySmall?.copyWith(color: scheme.error)),
        SheetActions(
          confirmLabel: isSaving ? 'Subiendo...' : 'Subir',
          enabled: !isSaving && form.documentType != null && file != null && form.fileError == null,
          isSaving: isSaving,
          onConfirm: onSave,
          onCancel: onDismiss,
        ),
      ],
    );
  }
}

String _contentTypeOf(String? extension) => switch (extension?.toLowerCase()) {
      'pdf' => 'application/pdf',
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      _ => 'application/octet-stream',
    };

String _formatLabel(String contentType) => switch (contentType) {
      'application/pdf' => 'PDF',
      'image/jpeg' => 'JPG',
      'image/png' => 'PNG',
      _ => contentType,
    };

String _sizeLabel(int bytes) {
  final double kb = bytes / 1024;
  return kb < 1024 ? '${kb.toStringAsFixed(0)} KB' : '${(kb / 1024).toStringAsFixed(1)} MB';
}
