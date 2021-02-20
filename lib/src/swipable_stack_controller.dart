import 'package:flutter/material.dart';

import 'swipable_stack.dart';

class SwipableStackController extends ChangeNotifier {
  SwipableStackController();

  final swipableStackStateKey = GlobalKey<SwipableStackState>();

  void moveNext({
    required SwipeDirection swipeDirection,
    bool shouldCallCompletionCallback = true,
  }) {
    swipableStackStateKey.currentState?.next(
      swipeDirection: swipeDirection,
      shouldCallCompletionCallback: shouldCallCompletionCallback,
    );
  }
}
