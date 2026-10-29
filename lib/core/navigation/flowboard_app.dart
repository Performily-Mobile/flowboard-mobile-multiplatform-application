import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/navigation/flowboard_bottom_bar.dart';
import 'package:flowboard/core/navigation/tab_navigator.dart';
import 'package:flowboard/core/navigation/top_level_destination.dart';
import 'package:flowboard/core/session/current_employee_provider.dart';

/// Root widget of the signed-in app: bottom bar by role plus one navigator per tab.
///
/// HR opens on the dashboard and employees on their home. Selecting a tab always shows its
/// first screen: the screens opened inside it are discarded.
class FlowboardApp extends StatefulWidget {
  /// Creates the shell.
  const FlowboardApp({super.key});

  @override
  State<FlowboardApp> createState() => _FlowboardAppState();
}

class _FlowboardAppState extends State<FlowboardApp> {
  late final List<TopLevelDestination> _destinations =
      TopLevelDestination.forRole(getIt<CurrentEmployeeProvider>().currentRole());

  late final List<GlobalKey<NavigatorState>> _navigatorKeys =
      List<GlobalKey<NavigatorState>>.generate(
    _destinations.length,
    (int index) => GlobalKey<NavigatorState>(),
  );

  int _selectedIndex = 0;

  void _onSelect(int index) {
    _navigatorKeys[index].currentState?.popUntil((Route<dynamic> route) => route.isFirst);
    setState(() => _selectedIndex = index);
  }

  Future<void> _onBack(bool didPop, Object? result) async {
    if (didPop) return;
    final NavigatorState? navigator = _navigatorKeys[_selectedIndex].currentState;
    if (navigator != null && await navigator.maybePop()) return;
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
    } else {
      await SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onBack,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: <Widget>[
            for (int i = 0; i < _destinations.length; i++)
              TabNavigator(navigatorKey: _navigatorKeys[i], initialRoute: _destinations[i].route),
          ],
        ),
        bottomNavigationBar: FlowboardBottomBar(
          destinations: _destinations,
          selectedIndex: _selectedIndex,
          onSelect: _onSelect,
        ),
      ),
    );
  }
}
