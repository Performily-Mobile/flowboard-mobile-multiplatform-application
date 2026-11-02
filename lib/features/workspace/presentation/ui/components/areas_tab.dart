import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_overflow_menu.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_colors.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/features/workspace/domain/entity/area.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/organization_list_item.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/status_chip.dart';

/// List of the areas of the organization.
///
/// [padding] is the padding of the list content; the screen adds the room for its collapsing
/// header and the bottom bar.
class AreasTab extends StatelessWidget {
  /// Creates the list.
  const AreasTab({super.key, required this.areas, required this.onDeactivateClick, required this.padding});

  final List<Area> areas;
  final ValueChanged<Area> onDeactivateClick;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      itemCount: areas.length,
      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: AppSpacing.itemGap),
      itemBuilder: (BuildContext context, int index) {
        final Area area = areas[index];
        return OrganizationListItem(
          key: ValueKey<int>(area.id),
          icon: FlowboardIcons.accountTree,
          title: area.name,
          subtitle: '${area.activeEmployees} colaboradores activos',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: <Widget>[
              LabelChip(
                text: area.active ? 'Activa' : 'Inactiva',
                containerColor: area.active ? AppColors.activeContainer : AppColors.surfaceContainerHigh,
              ),
              if (area.active)
                FlowboardOverflowMenu(
                  tooltip: 'Opciones del área',
                  actions: <FlowboardMenuAction>[
                    FlowboardMenuAction(
                      label: 'Desactivar área',
                      destructive: true,
                      onSelected: () => onDeactivateClick(area),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
