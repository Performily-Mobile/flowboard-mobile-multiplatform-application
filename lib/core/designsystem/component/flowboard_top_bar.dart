import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';

/// Single title bar used by every screen of the app.
///
/// It is placed at the top of the screen body, above an [Expanded] content, and handles the
/// status bar inset by itself. A round tonal button leads the bar when [onBack] or [onClose]
/// is given; screens opened from the bottom bar omit both.
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

    return Material(
      color: scheme.surface,
      child: SafeArea(
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
                  _NavigationButton(icon: FlowboardIcons.arrowBack, description: 'Volver', onPressed: onBack!),
                  const SizedBox(width: AppSpacing.m),
                ] else if (onClose != null) ...<Widget>[
                  _NavigationButton(icon: FlowboardIcons.close, description: 'Cerrar', onPressed: onClose!),
                  const SizedBox(width: AppSpacing.m),
                ],
                Expanded(
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
                ...actions,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Round tonal button at the start of a [FlowboardTopBar].
class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.icon,
    required this.description,
    required this.onPressed,
  });

  final IconData icon;
  final String description;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return IconButton.filledTonal(
      onPressed: onPressed,
      tooltip: description,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        fixedSize: const Size(40, 40),
        backgroundColor: scheme.surfaceContainerHigh,
        foregroundColor: scheme.onSurface,
      ),
    );
  }
}
