import 'package:flutter/material.dart';

/// Scroll behavior of the whole app: the native Android stretch, but much shorter.
///
/// Flutter cannot cap the stretch of the system indicator, so the drag is damped instead: once a
/// list is at its edge, every pixel the finger moves counts only [_edgeResistance] of a pixel
/// toward the stretch. It needs a long pull to reach even a small stretch, and lists still stop
/// at their edges.
class AppScrollBehavior extends MaterialScrollBehavior {
  /// Creates the behavior.
  const AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) => const _EdgeDampedPhysics();
}

class _EdgeDampedPhysics extends ClampingScrollPhysics {
  const _EdgeDampedPhysics({super.parent});

  /// Share of the finger movement that reaches the stretch once the list is at an edge.
  static const double _edgeResistance = 0.25;

  @override
  _EdgeDampedPhysics applyTo(ScrollPhysics? ancestor) => _EdgeDampedPhysics(parent: buildParent(ancestor));

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    final bool pullingPastTop = position.pixels <= position.minScrollExtent && offset > 0;
    final bool pullingPastBottom = position.pixels >= position.maxScrollExtent && offset < 0;
    if (pullingPastTop || pullingPastBottom) return offset * _edgeResistance;
    return super.applyPhysicsToUserOffset(position, offset);
  }
}
