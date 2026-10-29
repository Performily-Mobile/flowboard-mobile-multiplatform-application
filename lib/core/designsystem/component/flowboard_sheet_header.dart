import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';

/// Title of a bottom sheet or dialog, with the same text style as the top bar.
class FlowboardSheetHeader extends StatelessWidget {
  /// Creates the header with a [title] and an optional [subtitle].
  const FlowboardSheetHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface)),
          if (subtitle != null && subtitle!.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}
