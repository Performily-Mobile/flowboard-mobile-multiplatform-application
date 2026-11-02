import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';

/// Temporary screen for sections of bounded contexts that are not integrated yet.
///
/// It shows a back button only when there is a screen to go back to.
class PendingFeaturePage extends StatelessWidget {
  /// Creates the screen with the [title] shown in the top bar.
  const PendingFeaturePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NavigatorState navigator = Navigator.of(context);

    return Scaffold(
      body: Column(
        children: <Widget>[
          FlowboardTopBar(
            title: title,
            onBack: navigator.canPop() ? () => navigator.maybePop() : null,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.xl),
              child: Center(
                child: GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const GlassIconBadge(icon: FlowboardIcons.info, size: 72, iconSize: 32),
                      const SizedBox(height: AppSpacing.l),
                      Text(
                        'Esta sección todavía no está integrada en la app.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
