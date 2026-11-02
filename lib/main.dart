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
      locale: const Locale('es'),
      supportedLocales: const <Locale>[Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: const GlassBackground(child: FlowboardApp()),
    );
  }
}
