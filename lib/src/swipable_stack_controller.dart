import 'package:flutter/material.dart';
import 'package:swipable_stack/src/swipe_session.dart';

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

  SwipeSession? _currentSessionState;

  SwipeSession? get currentSession => _currentSessionState;

  set currentSession(SwipeSession? newValue) {
    if (_currentSessionState != newValue) {
      _currentSessionState = newValue;
      notifyListeners();
    }
  }

  SwipeSession? _previousSession;

  SwipeSession? get previousSession => _previousSession;

  set previousSession(SwipeSession? newValue) {
    if (_previousSession != newValue) {
      _previousSession = newValue;
      notifyListeners();
    }
  }

  bool get canRewind => previousSession != null;

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
