import 'package:flutter/material.dart';

/// Helper class that extends [ChangeNotifier].
///
/// Handles edge case when [notifyListeners] is called when [ViewModel] has been disposed.
///
/// Error usually occurs when we await a [Future] before calling [notifyListeners]
/// and in the meanwhile [ViewModel] has been disposed (ie. by navigation events).
class ViewModel extends ChangeNotifier {
  /// Flag to indicate if [ViewModel] has been disposed.
  bool disposed = false;

  /// Does not call `super.notifyListeners` if [ViewModel] has been disposed.
  @override
  void notifyListeners() {
    if (disposed) return;
    super.notifyListeners();
  }

  // Workaround to fix ChangeNotifier used on disposed because of Hero Widgets
  // on navigation events.
  // https://github.com/flutter/flutter/issues/36220.
  @override
  void removeListener(VoidCallback listener) {
    if (disposed) return;
    super.removeListener(listener);
  }

  @override
  @mustCallSuper
  void dispose() {
    disposed = true;
    super.dispose();
  }
}
