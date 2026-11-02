import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/theme/app_glass.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';

/// Glass bar for the main actions of a form ("Continuar", "Guardar", "Enviar"), placed in the
/// `bottomNavigationBar` slot of a [Scaffold].
///
/// It blurs the form behind it and keeps its buttons above the system navigation bar. Wrap each
/// button in [Expanded] to share the width.
class FlowboardBottomActionBar extends StatelessWidget {
  /// Creates the bar with the [children] buttons laid out in a row.
  const FlowboardBottomActionBar({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final GlassTokens tokens = GlassTokens.of(context);

    return ClipRect(
      child: BackdropFilter(
        filter: tokens.backdrop,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.glass,
            border: Border(top: BorderSide(color: tokens.border)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal, vertical: 12),
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
        ),
      ),
    );
  }
}
