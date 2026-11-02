import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/glass_surface.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_glass.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';

/// Single title bar used by every screen of the app.
///
/// It is placed at the top of the screen body, above an [Expanded] content, and handles the
/// status bar inset by itself. The bar is transparent over the glass background; a round glass
/// button leads it when [onBack] or [onClose] is given, and screens opened from the bottom bar
/// simply omit both.
class FlowboardTopBar extends StatelessWidget {
  /// Creates the bar.
  ///
  /// [title] is the screen title, [subtitle] an optional second line, [onBack] shows a back
  /// arrow, [onClose] shows a close icon when [onBack] is null, and [actions] are trailing widgets.
  const FlowboardTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.onClose,
    this.actions = const <Widget>[],
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final VoidCallback? onClose;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return SafeArea(
      bottom: false,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 72),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.m,
          ),
          child: Row(
            children: <Widget>[
              if (onBack != null) ...<Widget>[
                GlassCircleButton(icon: FlowboardIcons.arrowBack, tooltip: 'Volver', onPressed: onBack!),
                const SizedBox(width: AppSpacing.m),
              ] else if (onClose != null) ...<Widget>[
                GlassCircleButton(icon: FlowboardIcons.close, tooltip: 'Cerrar', onPressed: onClose!),
                const SizedBox(width: AppSpacing.m),
              ],
              Expanded(
                child: Semantics(
                  header: true,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(color: scheme.onSurface),
                      ),
                      if (subtitle != null && subtitle!.trim().isNotEmpty)
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
              ),
              ...actions,
            ],
          ),
        ),
      ),
    );
  }
}

/// Round glass button with an icon, used by the top bar and for trailing actions.
///
/// The visible circle is 40 dp, but the tap area keeps the 48 dp minimum.
class GlassCircleButton extends StatelessWidget {
  /// Creates the button with its [icon], accessibility [tooltip] and [onPressed] action.
  const GlassCircleButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final GlassTokens tokens = GlassTokens.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: GlassSurface(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              fill: tokens.control,
              sigma: tokens.blurSigma / 2,
              shadows: tokens.raised,
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onPressed,
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(icon, size: 20, color: scheme.onSurface),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
