import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';

/// Bar for the main actions of a form ("Continuar", "Guardar", "Enviar"), placed in the
/// `bottomNavigationBar` slot of a [Scaffold].
///
/// It keeps its buttons above the system navigation bar. Wrap each button in [Expanded] to
/// share the width.
class FlowboardBottomActionBar extends StatelessWidget {
  /// Creates the bar with the [children] buttons laid out in a row.
  const FlowboardBottomActionBar({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.5)),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: 12,
              ),
              child: Row(
                children: <Widget>[
                  for (int i = 0; i < children.length; i++) ...<Widget>[
                    if (i > 0) const SizedBox(width: AppSpacing.m),
                    children[i],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
