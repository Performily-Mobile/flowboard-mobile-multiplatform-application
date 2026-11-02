import 'package:flutter/widgets.dart';

/// Keeps one sheet or dialog in sync with a value of the view model state.
///
/// The Android app shows a sheet while a state flag is set and hides it when the flag is cleared.
/// Flutter opens modals imperatively, so this helper opens the modal when the value appears, closes
/// it when the value is cleared by the view model (for example after saving) and reports when the
/// user dismisses it by dragging or tapping outside.
class ModalSync<K extends Object> {
  /// Creates the helper.
  ///
  /// [open] shows the modal for a value and completes when it closes, and [onDismissed] tells the
  /// view model that the user closed it.
  ModalSync({required this.open, required this.onDismissed});

  final Future<void> Function(BuildContext context, K value) open;
  final VoidCallback onDismissed;

  K? _shown;
  int _generation = 0;
  NavigatorState? _navigator;

  /// Shows, swaps or closes the modal so it matches [desired].
  void sync(BuildContext context, K? desired) {
    if (desired == _shown) return;
    if (_shown != null) {
      _shown = null;
      _generation++;
      _navigator?.pop();
    }
    if (desired == null) return;
    _shown = desired;
    final int generation = ++_generation;
    _navigator = Navigator.of(context, rootNavigator: true);
    open(context, desired).whenComplete(() {
      if (generation == _generation) {
        _shown = null;
        onDismissed();
      }
    });
  }
}
