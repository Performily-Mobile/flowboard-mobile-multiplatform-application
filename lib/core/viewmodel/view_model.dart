import 'package:flutter/foundation.dart';

/// Base of every view model of the app.
///
/// It keeps an immutable UI state, like the `StateFlow` of the Android app, and notifies the
/// screen each time the state changes. Updates that arrive after the screen was closed are
/// ignored, so asynchronous calls never touch a disposed view model.
abstract class ViewModel<S> extends ChangeNotifier {
  /// Creates the view model with its [initialState].
  ViewModel(S initialState) : _state = initialState;

  S _state;
  bool _disposed = false;

  /// Current state of the screen.
  S get state => _state;

  /// True once the screen that owns the view model was closed.
  bool get isDisposed => _disposed;

  /// Replaces the state with the result of [transform] and notifies the screen.
  @protected
  void update(S Function(S current) transform) {
    if (_disposed) return;
    _state = transform(_state);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
