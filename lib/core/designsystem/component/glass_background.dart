import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/theme/app_glass.dart';

/// Flat background painted behind every screen.
///
/// It has no gradients or light spots: a calm, even surface keeps an HR tool clean and lets the
/// glass of the navigation layer stand out on its own.
class GlassBackground extends StatelessWidget {
  /// Creates the background with the screen [child] on top.
  const GlassBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: GlassTokens.of(context).background, child: child);
  }
}
