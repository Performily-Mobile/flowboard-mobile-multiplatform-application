import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/theme/app_glass.dart';

/// Piece of liquid glass: blurs and saturates what is behind it.
///
/// Its contour is a single thin light rim ([GlassTokens.glassBorder]), like the edge of a real
/// glass catching the light, and its separation from the content comes from a soft shadow, never
/// from a dark outline. Used by the bottom bar and the round top bar buttons.
class GlassSurface extends StatelessWidget {
  /// Creates the glass with its [child] and corner [borderRadius].
  const GlassSurface({
    super.key,
    required this.child,
    required this.borderRadius,
    this.fill,
    this.sigma,
    this.shadows,
  });

  final Widget child;
  final BorderRadius borderRadius;

  /// Replaces the translucent fill of the tokens.
  final Color? fill;

  /// Replaces the blur of the tokens, for small controls.
  final double? sigma;

  /// Replaces the floating shadow; pass an empty list for none.
  final List<BoxShadow>? shadows;

  @override
  Widget build(BuildContext context) {
    final GlassTokens tokens = GlassTokens.of(context);
    final List<BoxShadow> boxShadows = shadows ?? tokens.elevation;

    final Widget glass = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: sigma == null ? tokens.backdrop : tokens.backdropWith(sigma!),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill ?? tokens.glass,
            borderRadius: borderRadius,
            border: Border.all(color: tokens.glassBorder),
          ),
          child: child,
        ),
      ),
    );

    if (boxShadows.isEmpty) return glass;
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: borderRadius, boxShadow: boxShadows),
      child: glass,
    );
  }
}
