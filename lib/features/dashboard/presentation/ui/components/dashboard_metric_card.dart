import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/features/dashboard/presentation/ui/components/dashboard_accent.dart';

/// Indicator card of the dashboard: tinted icon, large value, title and an optional note.
class DashboardMetricCard extends StatelessWidget {
  /// Creates the card; [onTap] opens the detail behind the indicator.
  const DashboardMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.onTap,
    this.supportingText,
  });

  final String label;
  final String value;
  final IconData icon;
  final DashboardAccent accent;
  final VoidCallback onTap;
  final String? supportingText;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Brightness brightness = theme.brightness;
    final String? note = supportingText;

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.l),
      semanticLabel: <String>[label, value, if (note != null) note].join(', '),
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(shape: BoxShape.circle, color: accent.container(brightness)),
              child: Icon(icon, size: 20, color: accent.content(brightness)),
            ),
            Text(value, style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            if (note != null)
              Text(note, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
