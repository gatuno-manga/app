import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

/// A base ViewModel class that manages state using a [BehaviorSubject].
/// It replaces [ChangeNotifier] for reactive state management.
abstract class BaseStreamViewModel<T> {
  final BehaviorSubject<T> _stateSubject;

  BaseStreamViewModel(T initialState)
      : _stateSubject = BehaviorSubject<T>.seeded(initialState);

  /// The stream of state changes. UI components should listen to this.
  Stream<T> get stateStream => _stateSubject.stream;

  /// The current state synchronously.
  T get state => _stateSubject.value;

  /// Emits a new state.
  @protected
  void emit(T newState) {
    if (!_stateSubject.isClosed) {
      _stateSubject.add(newState);
    }
  }

  /// Closes the underlying subject. Must be called when the ViewModel is disposed.
  @mustCallSuper
  void dispose() {
    _stateSubject.close();
  }
}
