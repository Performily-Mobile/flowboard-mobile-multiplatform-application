import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/features/workspace/domain/entity/position.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/organization_list_item.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/status_chip.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/workspace_labels.dart';

/// List of the positions of the organization.
///
/// [padding] is the padding of the list content; the screen adds the room for its collapsing
/// header and the bottom bar.
class PositionsTab extends StatelessWidget {
  /// Creates the list.
  const PositionsTab({super.key, required this.positions, required this.padding});

  final List<Position> positions;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      itemCount: positions.length,
      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: AppSpacing.itemGap),
      itemBuilder: (BuildContext context, int index) {
        final Position position = positions[index];
        return OrganizationListItem(
          key: ValueKey<int>(position.id),
          icon: FlowboardIcons.person,
          title: position.title,
          subtitle: '${position.areaName} · Sueldo ref. ${position.referenceSalary.display}',
          trailing: ActiveChip(active: position.active),
        );
      },
    );
  }
}
