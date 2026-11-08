import 'dart:ui' show PathMetric;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_glass.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/features/payroll/presentation/state/upload_payslips_ui_state.dart';

/// Dashed zone to pick the PDFs exported by the payroll system (MA-67).
///
/// Every kind of file can be picked so the screen can explain why a file is rejected, as in the
/// prototype ("boletas_setiembre.xlsx no es un formato permitido").
class PayslipUploadZone extends StatelessWidget {
  /// Creates the zone.
  const PayslipUploadZone({
    super.key,
    required this.enabled,
    required this.supportingText,
    required this.onFilesSelected,
  });

  final bool enabled;
  final String supportingText;
  final ValueChanged<List<SelectedPayslipFile>> onFilesSelected;

  static const double _radius = 20;

  Future<void> _pick() async {
    final List<PlatformFile> picked = await FilePicker.pickFiles();
    if (picked.isEmpty) return;
    final List<SelectedPayslipFile> files = <SelectedPayslipFile>[];
    for (final PlatformFile file in picked) {
      final int size = file.lengthSync() ?? await file.length() ?? 0;
      files.add(SelectedPayslipFile(
        path: file.path ?? '',
        name: file.name,
        contentType: (file.extension ?? '').toLowerCase() == 'pdf' ? 'application/pdf' : 'application/octet-stream',
        sizeInBytes: size,
      ));
    }
    onFilesSelected(files);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Seleccionar archivos del sistema de planilla',
      child: CustomPaint(
        foregroundPainter: _DashedBorderPainter(color: scheme.outline, radius: _radius),
        child: Material(
          color: GlassTokens.of(context).surface,
          borderRadius: const BorderRadius.all(Radius.circular(_radius)),
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(_radius)),
            onTap: enabled ? _pick : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: AppSpacing.xl),
              child: Column(
                spacing: AppSpacing.s,
                children: <Widget>[
                  Icon(FlowboardIcons.upload, size: 28, color: scheme.onSurfaceVariant),
                  Text(
                    'Seleccionar archivos del sistema de planilla',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: scheme.onSurface),
                  ),
                  Text(
                    supportingText,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 1 dp border with 4 dp dashes around a rounded rectangle.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const double _dash = 4;
  static const double _gap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final RRect rect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)).deflate(0.5);
    final Path path = Path()..addRRect(rect);
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + _dash), paint);
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => oldDelegate.color != color || oldDelegate.radius != radius;
}
