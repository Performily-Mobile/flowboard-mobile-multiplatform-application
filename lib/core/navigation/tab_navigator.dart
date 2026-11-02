import 'package:flutter/material.dart';
import 'package:flowboard/core/navigation/app_router.dart';

/// Navigator of one tab of the bottom bar.
///
/// Each tab keeps its own stack, so the bar stays visible on inner screens. Full-screen forms
/// are opened with `Navigator.of(context, rootNavigator: true)` to cover the bar.
///
/// The stack starts with the tab root only. The default behavior splits names such as
/// `/employees` into `/` and `/employees`, which left a placeholder page under every tab.
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
      onGenerateInitialRoutes: (NavigatorState navigator, String name) => <Route<dynamic>>[
        AppRouter.onGenerateRoute(RouteSettings(name: name)),
      ],
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
