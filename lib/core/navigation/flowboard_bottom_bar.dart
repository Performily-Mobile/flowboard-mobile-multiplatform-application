import 'package:flutter/material.dart';
import 'package:flowboard/core/navigation/top_level_destination.dart';

/// Bottom navigation bar of the app shell, with one item per destination of the role.
class FlowboardBottomBar extends StatelessWidget {
  /// Creates the bar with the [destinations] shown, the [selectedIndex] and [onSelect].
  const FlowboardBottomBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<TopLevelDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelect,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: <Widget>[
        for (final TopLevelDestination destination in destinations)
          NavigationDestination(icon: Icon(destination.icon), label: destination.label),
      ],
    );
  }
}
