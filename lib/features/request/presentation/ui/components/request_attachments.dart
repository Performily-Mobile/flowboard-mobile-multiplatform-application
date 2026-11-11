import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_shapes.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/domain/file_reference.dart';
import 'package:flowboard/features/request/presentation/state/picked_attachment.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_colors.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_common.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_formatters.dart';

/// Opens the file picker limited to PDF, JPG and PNG; returns null when nothing was chosen.
Future<PickedAttachment?> pickAttachment() async {
  final PlatformFile? picked = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: const <String>['pdf', 'jpg', 'jpeg', 'png'],
  );
  if (picked == null) return null;
  final int size = await picked.length() ?? 0;
  return PickedAttachment(
    uri: picked.path ?? '',
    name: picked.name,
    contentType: _contentTypeOf(picked.extension),
    sizeInBytes: size,
  );
}

String _contentTypeOf(String? extension) => switch (extension?.toLowerCase()) {
      'pdf' => 'application/pdf',
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      _ => 'application/octet-stream',
    };

/// Dashed zone that opens the file picker to attach a supporting file.
class AttachmentZone extends StatelessWidget {
  /// Creates the zone; [isRequired] tells whether the request type needs an attachment.
  const AttachmentZone({
    super.key,
    required this.isRequired,
    required this.isUploading,
    required this.onPicked,
    this.error,
  });

  final bool isRequired;
  final bool isUploading;
  final ValueChanged<PickedAttachment> onPicked;
  final String? error;

  Future<void> _pick() async {
    final PickedAttachment? file = await pickAttachment();
    if (file != null) onPicked(file);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.xs,
      children: <Widget>[
        CustomPaint(
          foregroundPainter: _DashedBorderPainter(color: error != null ? scheme.error : scheme.outline),
          child: Material(
            color: RequestColors.attachmentZone,
            borderRadius: AppShapes.medium,
            child: InkWell(
              borderRadius: AppShapes.medium,
              onTap: isUploading ? null : _pick,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Row(
                  spacing: AppSpacing.m,
                  children: <Widget>[
                    if (isUploading)
                      const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    else
                      Icon(FlowboardIcons.attachFile, color: scheme.onSurfaceVariant),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: <Widget>[
                          Text(
                            isRequired ? 'Adjuntar sustento' : 'Adjuntar sustento (opcional)',
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'PDF, JPG o PNG · máx. 5 MB',
                            style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (error != null) Text(error!, style: theme.textTheme.bodySmall?.copyWith(color: scheme.error)),
      ],
    );
  }
}

/// Card of an attached file, with an optional button to remove it.
class AttachmentRow extends StatelessWidget {
  /// Creates the card; [onRemove] null hides the remove button.
  const AttachmentRow({super.key, required this.file, this.onRemove});

  final FileReference file;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
      child: Row(
        spacing: AppSpacing.m,
        children: <Widget>[
          RequestIconCircle(
            icon: Icons.description_outlined,
            containerColor: scheme.surfaceContainer,
            contentColor: scheme.onSurfaceVariant,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: <Widget>[
                Text(
                  file.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  RequestFormatters.fileDetail(file),
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(tooltip: 'Quitar adjunto', onPressed: onRemove, icon: const Icon(FlowboardIcons.close)),
        ],
      ),
    );
  }
}

/// Paints a dashed rounded border around the attachment zone.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color});

  final Color color;

  static const double _dash = 6;
  static const double _gap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final RRect border = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(AppShapes.mediumRadius),
    ).deflate(0.5);
    final Path path = Path()..addRRect(border);
    for (final ui.PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + _dash), paint);
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => oldDelegate.color != color;
}
