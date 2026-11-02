import 'package:flutter/widgets.dart';

/// Builds the page of a route of a bounded context, or returns null when the route is not its own.
typedef FeaturePageBuilder = Widget? Function(RouteSettings settings);

/// Routes registered by the bounded contexts.
///
/// Each context registers its page builder in its dependency setup, so the core navigation never
/// imports the screens of a feature. Routes that no context resolves show a temporary screen.
class FeatureRouteRegistry {
  final List<FeaturePageBuilder> _builders = <FeaturePageBuilder>[];

  /// Adds the page [builder] of a bounded context.
  void register(FeaturePageBuilder builder) => _builders.add(builder);

  /// Page of the first bounded context that knows [settings], or null.
  Widget? resolve(RouteSettings settings) {
    for (final FeaturePageBuilder builder in _builders) {
      final Widget? page = builder(settings);
      if (page != null) return page;
    }
    return null;
  }
}
