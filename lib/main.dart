import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flowboard/core/designsystem/component/glass_background.dart';
import 'package:flowboard/core/designsystem/theme/app_theme.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/navigation/app_router.dart';
import 'package:flowboard/core/navigation/flowboard_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  runApp(const MainApp());
}

/// Root of the app: glass theme, Spanish locale and the signed-in shell.
///
/// Full-screen forms are pushed on the root navigator, above the bottom bar, through
/// [AppRouter.onGenerateRoute].
class MainApp extends StatelessWidget {
  /// Creates the root widget.
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flowboard',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _SoftStretchScrollBehavior(),
      locale: const Locale('es'),
      supportedLocales: const <Locale>[Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: const GlassBackground(child: FlowboardApp()),
    );
  }
}

/// Keeps the native Android stretch but makes it much shorter.
///
/// Flutter cannot cap the stretch of the system indicator, so the drag is damped instead: once a
/// list is at its edge, every pixel the finger moves counts only [_edgeResistance] of a pixel
/// toward the stretch. It needs a long pull to reach even a small stretch, and lists still stop
/// at their edges.
class _SoftStretchScrollBehavior extends MaterialScrollBehavior {
  const _SoftStretchScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) => const _EdgeDampedPhysics();
}

class _EdgeDampedPhysics extends ClampingScrollPhysics {
  const _EdgeDampedPhysics({super.parent});

  /// Share of the finger movement that reaches the stretch once the list is at an edge.
  static const double _edgeResistance = 0.25;

  @override
  _EdgeDampedPhysics applyTo(ScrollPhysics? ancestor) => _EdgeDampedPhysics(parent: buildParent(ancestor));

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    final bool pullingPastTop = position.pixels <= position.minScrollExtent && offset > 0;
    final bool pullingPastBottom = position.pixels >= position.maxScrollExtent && offset < 0;
    if (pullingPastTop || pullingPastBottom) return offset * _edgeResistance;
    return super.applyPhysicsToUserOffset(position, offset);
  }
}
