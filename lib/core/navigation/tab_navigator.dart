import 'package:flutter/material.dart';
import 'package:flowboard/core/navigation/app_router.dart';

/// Navigator of one tab of the bottom bar.
///
/// Each tab keeps its own stack, so the bar stays visible on inner screens. Full-screen forms
/// are opened with `Navigator.of(context, rootNavigator: true)` to cover the bar.
class TabNavigator extends StatelessWidget {
  /// Creates the navigator with its [navigatorKey] and the [initialRoute] of the tab.
  const TabNavigator({super.key, required this.navigatorKey, required this.initialRoute});

  final GlobalKey<NavigatorState> navigatorKey;
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: initialRoute,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
