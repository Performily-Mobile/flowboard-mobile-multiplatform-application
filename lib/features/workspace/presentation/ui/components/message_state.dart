import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';

/// Centered glass card with a title, a message and an optional action, used for the error and
/// empty states of the workspace screens.
class MessageState extends StatelessWidget {
  /// Creates the state; [actionLabel] null hides the button.
  const MessageState({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.topPadding = 48,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, topPadding, AppSpacing.screenHorizontal, 0),
      child: Align(
        alignment: Alignment.topCenter,
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.s,
            children: <Widget>[
              Text(title, textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              if (actionLabel != null) ...<Widget>[
                const SizedBox(height: AppSpacing.xs),
                OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
