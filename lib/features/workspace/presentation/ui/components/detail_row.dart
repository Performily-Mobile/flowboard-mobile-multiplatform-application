import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';

/// Read-only label and value pair, usually placed inside an [InfoPanel].
///
/// A dash is shown when [value] is blank.
class DetailRow extends StatelessWidget {
  /// Creates the row.
  const DetailRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: <Widget>[
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            Text(
              value.trim().isEmpty ? '—' : value,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}

/// Glass panel that groups several [DetailRow]s of the same topic.
class InfoPanel extends StatelessWidget {
  /// Creates the panel with its [children] rows.
  const InfoPanel({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ),
    );
  }
}

/// Title of a block of content inside a screen or a tab.
class SectionTitle extends StatelessWidget {
  /// Creates the title.
  const SectionTitle(this.text, {super.key, this.topPadding = 8});

  final String text;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(top: topPadding, bottom: 4),
      child: Semantics(
        header: true,
        child: Text(text, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface)),
      ),
    );
  }
}
