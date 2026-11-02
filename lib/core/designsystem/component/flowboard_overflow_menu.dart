import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';

/// One entry of a [FlowboardOverflowMenu].
class FlowboardMenuAction {
  /// Creates the entry with its [label], the [onSelected] action and whether it is [destructive].
  const FlowboardMenuAction({required this.label, required this.onSelected, this.destructive = false});

  final String label;
  final VoidCallback onSelected;
  final bool destructive;
}

/// "More options" button that opens a glass menu with the given [actions].
class FlowboardOverflowMenu extends StatelessWidget {
  /// Creates the menu.
  const FlowboardOverflowMenu({super.key, required this.actions, this.tooltip = 'Más opciones'});

  final List<FlowboardMenuAction> actions;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return MenuAnchor(
      menuChildren: <Widget>[
        for (final FlowboardMenuAction action in actions)
          MenuItemButton(
            onPressed: action.onSelected,
            child: Text(
              action.label,
              style: action.destructive ? TextStyle(color: scheme.error) : null,
            ),
          ),
      ],
      builder: (BuildContext context, MenuController controller, Widget? child) {
        return IconButton(
          tooltip: tooltip,
          icon: const Icon(FlowboardIcons.moreVert),
          onPressed: () => controller.isOpen ? controller.close() : controller.open(),
        );
      },
    );
  }
}
