import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/theme/app_glass.dart';
import 'package:flowboard/core/designsystem/theme/app_shapes.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';

/// Opens a [GlassDialog] built by [builder] over a scrim.
Future<T?> showGlassDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showDialog<T>(
    context: context,
    useRootNavigator: true,
    barrierColor: GlassTokens.of(context).scrim,
    builder: builder,
  );
}

/// Glass version of an alert dialog: optional icon, title, content and actions.
class GlassDialog extends StatelessWidget {
  /// Creates the dialog.
  ///
  /// [icon] is drawn above the title, [content] scrolls when it is long and [actions] are laid
  /// out at the end, right aligned.
  const GlassDialog({
    super.key,
    required this.title,
    required this.content,
    this.icon,
    this.actions = const <Widget>[],
  });

  final String title;
  final Widget content;
  final Widget? icon;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final GlassTokens tokens = GlassTokens.of(context);
    const BorderRadius radius = AppShapes.extraLarge;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xl),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: tokens.backdrop,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: tokens.overlay,
              borderRadius: radius,
              border: Border.all(color: tokens.glassBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.l),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: icon == null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    IconTheme(
                      data: IconThemeData(size: 24, color: theme.colorScheme.secondary),
                      child: icon!,
                    ),
                    const SizedBox(height: AppSpacing.l),
                  ],
                  Text(
                    title,
                    textAlign: icon == null ? TextAlign.start : TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(fontSize: 22, height: 28 / 22),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Align(alignment: Alignment.centerLeft, child: content),
                    ),
                  ),
                  if (actions.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppSpacing.xl),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: AppSpacing.s,
                      runSpacing: AppSpacing.s,
                      children: actions,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
