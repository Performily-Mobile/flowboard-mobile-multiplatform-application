import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flowboard/core/navigation/app_router.dart';

/// Navigator of one tab of the bottom bar.
///
/// Each tab keeps its own stack, so the bar stays visible on inner screens. Full-screen forms
/// are opened with `Navigator.of(context, rootNavigator: true)` to cover the bar.
///
/// The stack starts with the tab root only. The default behavior splits names such as
/// `/employees` into `/` and `/employees`, which left a placeholder page under every tab.
///
/// The bottom bar floats over the tab, so its height is also given as view padding: the
/// [Scaffold] of each screen places its floating button above that padding, not behind the bar.
class TabNavigator extends StatelessWidget {
  /// Creates the navigator with its [navigatorKey] and the [initialRoute] of the tab.
  const TabNavigator({super.key, required this.navigatorKey, required this.initialRoute});

  final GlobalKey<NavigatorState> navigatorKey;
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        viewPadding: media.viewPadding.copyWith(bottom: math.max(media.viewPadding.bottom, media.padding.bottom)),
      ),
      child: Navigator(
        key: navigatorKey,
        initialRoute: initialRoute,
        onGenerateInitialRoutes: (NavigatorState navigator, String name) => <Route<dynamic>>[
          AppRouter.onGenerateRoute(RouteSettings(name: name)),
        ],
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
