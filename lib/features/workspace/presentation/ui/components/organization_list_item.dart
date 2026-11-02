import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';

/// Glass card used by the lists of areas and positions.
///
/// [trailing] is optional content at the end of the card (status chip, menu).
class OrganizationListItem extends StatelessWidget {
  /// Creates the card.
  const OrganizationListItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GlassCard(
      padding: EdgeInsets.only(left: 16, right: trailing != null ? 12 : 16, top: 14, bottom: 14),
      child: Row(
        spacing: AppSpacing.m,
        children: <Widget>[
          GlassIconBadge(icon: icon),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: <Widget>[
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyLarge),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
