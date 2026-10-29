import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/theme/app_theme.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/navigation/flowboard_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  runApp(const MainApp());
}

/// Root of the app: theme and the signed-in shell.
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
      home: const FlowboardApp(),
    );
  }
}
