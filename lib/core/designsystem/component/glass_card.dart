import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/theme/app_glass.dart';
import 'package:flowboard/core/designsystem/theme/app_shapes.dart';

/// Card used by every list row and info block of the app.
///
/// It replaces the tonal surfaces of the Android app with the same radius, padding and content:
/// an opaque clean surface with a hairline edge and no shadow, so the content layer stays flat
/// under the glass navigation. With [blur] it becomes floating glass instead.
class GlassCard extends StatelessWidget {
  /// Creates the card.
  ///
  /// [onTap] makes the whole card tappable with a ripple, [padding] is applied inside the
  /// glass, [tint] replaces the fill (for highlighted or pending items), [borderColor] replaces
  /// the edge, [strong] is kept for compatibility (same surface) and [blur] turns it into glass.
  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = EdgeInsets.zero,
    this.radius = AppShapes.mediumRadius,
    this.tint,
    this.borderColor,
    this.strong = false,
    this.blur = false,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? tint;
  final Color? borderColor;
  final bool strong;
  final bool blur;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final GlassTokens tokens = GlassTokens.of(context);
    final BorderRadius borderRadius = BorderRadius.circular(radius);
    final bool glass = blur && tokens.blurSigma > 0;
    final Color base = tint ?? (glass ? tokens.glass : tokens.surface);

    Widget content = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Padding(padding: padding, child: child),
      ),
    );

    content = DecoratedBox(
      decoration: BoxDecoration(
        color: base,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor ?? (glass ? tokens.glassBorder : tokens.border)),
      ),
      child: content,
    );

    if (glass) {
      content = BackdropFilter(
        filter: tokens.backdrop,
        child: content,
      );
    }

    final Widget clipped = ClipRRect(borderRadius: borderRadius, child: content);
    final Widget card = glass
        ? DecoratedBox(
            decoration: BoxDecoration(borderRadius: borderRadius, boxShadow: tokens.elevation),
            child: clipped,
          )
        : clipped;

    if (semanticLabel == null) return card;
    return Semantics(label: semanticLabel, button: onTap != null, child: card);
  }
}

/// Round tonal circle with an icon, used as the leading element of list rows.
class GlassIconBadge extends StatelessWidget {
  /// Creates the badge with its [icon] and [size].
  const GlassIconBadge({super.key, required this.icon, this.size = 40, this.iconSize = 20});

  final IconData icon;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.secondaryContainer,
      ),
      child: Icon(icon, size: iconSize, color: scheme.onSecondaryContainer),
    );
  }
}
