import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/glass_surface.dart';
import 'package:flowboard/core/navigation/top_level_destination.dart';

/// Floating liquid glass bottom bar of the app shell, with one item per destination of the role.
///
/// The content of the tabs scrolls behind it and is blurred, which keeps the place of the user in
/// view while making the navigation the top layer.
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

  static const double _radius = 28;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(_radius);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: GlassSurface(
          borderRadius: radius,
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onSelect,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: <Widget>[
              for (final TopLevelDestination destination in destinations)
                NavigationDestination(icon: Icon(destination.icon), label: destination.label),
            ],
          ),
        ),
      ),
    );
  }
}
