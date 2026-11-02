import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/theme/app_glass.dart';
import 'package:flowboard/core/designsystem/theme/app_shapes.dart';

/// Opens a glass bottom sheet above the bottom bar.
///
/// The sheet grows with its content, moves above the keyboard and can be dismissed by dragging
/// it down or tapping the scrim.
Future<T?> showGlassBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: GlassTokens.of(context).scrim,
    builder: (BuildContext sheetContext) => GlassSheetContainer(child: builder(sheetContext)),
  );
}

/// Blurred glass container of a bottom sheet, with its drag handle.
class GlassSheetContainer extends StatelessWidget {
  /// Creates the container around the sheet [child].
  const GlassSheetContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final GlassTokens tokens = GlassTokens.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    const BorderRadius radius = BorderRadius.vertical(top: Radius.circular(AppShapes.extraLargeRadius));

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: tokens.backdrop,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: tokens.overlay,
              borderRadius: radius,
              border: Border(top: BorderSide(color: tokens.glassBorder)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 12),
                    child: Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                        borderRadius: AppShapes.pill,
                      ),
                    ),
                  ),
                  Flexible(child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
