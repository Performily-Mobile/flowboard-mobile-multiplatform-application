import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/theme/app_colors.dart';
import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/features/workspace/domain/valueobject/organization_chart_node.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/employee_avatar.dart';

/// Node of the organization chart: the employee card followed by its direct reports, indented
/// behind a vertical guide line.
///
/// [highlightedEmployeeId] marks the current user with "(tú)".
class OrganizationChartNodeItem extends StatelessWidget {
  /// Creates the node.
  const OrganizationChartNodeItem({super.key, required this.node, this.highlightedEmployeeId});

  final OrganizationChartNode node;
  final EmployeeId? highlightedEmployeeId;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isHighlighted = node.employeeId == highlightedEmployeeId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: <Widget>[
        _NodeCard(
          initials: node.initials,
          title: isHighlighted ? '${node.fullName} (tú)' : node.fullName,
          subtitle: node.positionTitle,
          tint: isHighlighted ? scheme.secondaryContainer : null,
          borderColor: isHighlighted ? scheme.primary : null,
        ),
        if (node.subordinates.isNotEmpty)
          Container(
            padding: const EdgeInsets.only(left: 14),
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: AppColors.outlineVariant, width: 2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: <Widget>[
                for (final OrganizationChartNode child in node.subordinates)
                  OrganizationChartNodeItem(node: child, highlightedEmployeeId: highlightedEmployeeId),
              ],
            ),
          ),
      ],
    );
  }
}

/// Card of an employee whose direct manager was terminated and who waits for a new one.
class PendingNodeCard extends StatelessWidget {
  /// Creates the card.
  const PendingNodeCard({super.key, required this.node});

  final OrganizationChartNode node;

  @override
  Widget build(BuildContext context) {
    return _NodeCard(
      initials: node.initials,
      title: node.fullName,
      subtitle: '${node.positionTitle} · jefe cesado',
      tint: AppColors.pendingContainer,
      borderColor: AppColors.pendingOutline,
    );
  }
}

/// Glass card with avatar, name and position of one employee of the chart.
class _NodeCard extends StatelessWidget {
  const _NodeCard({
    required this.initials,
    required this.title,
    required this.subtitle,
    this.tint,
    this.borderColor,
  });

  final String initials;
  final String title;
  final String subtitle;
  final Color? tint;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GlassCard(
      tint: tint,
      borderColor: borderColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        spacing: 12,
        children: <Widget>[
          EmployeeAvatar(initials: initials, size: 32),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyLarge),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
