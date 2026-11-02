import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/features/workspace/domain/entity/employee_document.dart';
import 'package:flowboard/features/workspace/domain/valueobject/document_type.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/workspace_labels.dart';

/// Documents of an employee record with category filter chips and download buttons.
///
/// When [onUploadClick] is not null the "Subir documento" button is shown.
class DocumentsTab extends StatelessWidget {
  /// Creates the tab.
  const DocumentsTab({
    super.key,
    required this.documents,
    required this.selectedCategory,
    required this.onCategoryChange,
    this.onUploadClick,
  });

  final List<EmployeeDocument> documents;
  final DocumentCategory? selectedCategory;
  final ValueChanged<DocumentCategory?> onCategoryChange;
  final VoidCallback? onUploadClick;

  Future<void> _open(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.itemGap,
      children: <Widget>[
        if (onUploadClick != null)
          OutlinedButton.icon(
            onPressed: onUploadClick,
            icon: const Icon(FlowboardIcons.upload),
            label: const Text('Subir documento'),
          ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: AppSpacing.s,
            children: <Widget>[
              _CategoryChip(label: 'Todos', selected: selectedCategory == null, onTap: () => onCategoryChange(null)),
              _CategoryChip(
                label: 'Contratos',
                selected: selectedCategory == DocumentCategory.contract,
                onTap: () => onCategoryChange(DocumentCategory.contract),
              ),
              _CategoryChip(
                label: 'Constancias',
                selected: selectedCategory == DocumentCategory.certificate,
                onTap: () => onCategoryChange(DocumentCategory.certificate),
              ),
              _CategoryChip(
                label: 'Personales',
                selected: selectedCategory == DocumentCategory.personal,
                onTap: () => onCategoryChange(DocumentCategory.personal),
              ),
            ],
          ),
        ),
        if (documents.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No hay documentos en el expediente.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        for (final EmployeeDocument document in documents)
          GlassCard(
            padding: const EdgeInsets.only(left: 16, right: 4, top: 10, bottom: 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: <Widget>[
                      Text(
                        document.documentType.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge,
                      ),
                      Text(
                        '${document.documentType.category.label} · Cargado el ${formatDisplayDate(document.uploadedAt)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Descargar',
                  icon: const Icon(FlowboardIcons.download),
                  onPressed: () => _open(document.file.storageUrl),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Filter chip of one document category.
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (bool _) => onTap(),
    );
  }
}
