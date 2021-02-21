import 'package:flutter/material.dart';
import 'package:swipable_stack/src/swipe_session_state.dart';

import 'swipable_stack.dart';

class SwipableStackController extends ChangeNotifier {
  SwipableStackController({
    int initialIndex = 0,
  })  : _currentIndex = initialIndex,
        assert(initialIndex >= 0);

  final swipableStackStateKey = GlobalKey<SwipableStackState>();

  int _currentIndex;

  int get currentIndex => _currentIndex;

  set currentIndex(int newValue) {
    if (_currentIndex != newValue) {
      _currentIndex = newValue;
      notifyListeners();
    }
  }

  SwipeSessionState? _currentSessionState;

  SwipeSessionState? get currentSessionState => _currentSessionState;

  set currentSessionState(SwipeSessionState? newValue) {
    if (_currentSessionState != newValue) {
      _currentSessionState = newValue;
      notifyListeners();
    }
  }

  SwipeSessionState? _previousSessionState;

  SwipeSessionState? get previousSessionState => _previousSessionState;

  set previousSessionState(SwipeSessionState? newValue) {
    if (_previousSessionState != newValue) {
      _previousSessionState = newValue;
      notifyListeners();
    }
  }

  bool get canRewind => previousSessionState != null;

  void moveNext({
    required SwipeDirection swipeDirection,
    bool shouldCallCompletionCallback = true,
  }) {
    swipableStackStateKey.currentState?.next(
      swipeDirection: swipeDirection,
      shouldCallCompletionCallback: shouldCallCompletionCallback,
    );
  }

  void rewind() {
    swipableStackStateKey.currentState?.rewind();
  }
}
