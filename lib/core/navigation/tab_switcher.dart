/// Lets a screen switch the tab of the bottom bar without knowing the shell that owns it.
///
/// The shell attaches its handler while it is on screen; a screen asks to show the tab whose first
/// route is given, for example the dashboard card "Solicitudes pendientes" opening that tab.
class TabSwitcher {
  void Function(String route)? _handler;

  /// Registers the shell handler that selects a tab by the route of its first screen.
  void attach(void Function(String route) handler) => _handler = handler;

  /// Removes the handler when the shell leaves the screen.
  void detach() => _handler = null;

  /// Shows the tab whose first screen is [route]; does nothing when no shell is attached.
  void switchTo(String route) => _handler?.call(route);
}
