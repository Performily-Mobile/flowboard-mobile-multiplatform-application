import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/glass_surface.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_glass.dart';
import 'package:flowboard/core/designsystem/theme/app_shapes.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';

/// Liquid glass pill button, like the round glass buttons of the top bar of Workspace.
///
/// With [expanded] it fills the width, as the "Ver estado de pagos" access of "Boletas y pagos".
class PayrollGlassButton extends StatelessWidget {
  /// Creates the button with its [label], an optional leading [icon] and [onPressed] action.
  const PayrollGlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.expanded = false,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool expanded;
  final double height;

  @override
  Widget build(BuildContext context) {
    final GlassTokens tokens = GlassTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final bool enabled = onPressed != null;
    final Color color = enabled ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.38);
    final IconData? leading = icon;
    final IconData? trailing = trailingIcon;
    return Semantics(
      button: true,
      enabled: enabled,
      child: GlassSurface(
        borderRadius: AppShapes.pill,
        fill: tokens.control,
        sigma: tokens.blurSigma / 2,
        shadows: tokens.raised,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onPressed,
            child: SizedBox(
              height: height,
              width: expanded ? double.infinity : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: AppSpacing.s,
                  children: <Widget>[
                    if (leading != null) Icon(leading, size: 20, color: color),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(color: color),
                      ),
                    ),
                    if (trailing != null) Icon(trailing, size: 20, color: color),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Liquid glass block with a title row that shows or hides its [child]: "Cargar y publicar boletas".
class PayrollExpandableSection extends StatelessWidget {
  /// Creates the section; [expanded] says whether [child] is visible.
  const PayrollExpandableSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final GlassTokens tokens = GlassTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return GlassSurface(
      borderRadius: AppShapes.large,
      fill: tokens.control,
      sigma: tokens.blurSigma / 2,
      shadows: tokens.raised,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Semantics(
              button: true,
              expanded: expanded,
              child: InkWell(
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.m, AppSpacing.m, AppSpacing.m),
                  child: Row(
                    spacing: AppSpacing.m,
                    children: <Widget>[
                      Icon(icon, size: 22, color: scheme.primary),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 2,
                          children: <Widget>[
                            Text(title, style: theme.textTheme.titleSmall?.copyWith(color: scheme.onSurface)),
                            Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        turns: expanded ? 0.25 : -0.25,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(FlowboardIcons.chevronRight, color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: expanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.l, 0, AppSpacing.l, AppSpacing.l),
                      child: child,
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}
