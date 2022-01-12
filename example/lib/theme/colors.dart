import 'package:flutter/material.dart';
import 'package:swipable_stack/swipable_stack.dart';

class SwipeDirectionColor {
  static const right = Color.fromRGBO(70, 195, 120, 1);
  static const left = Color.fromRGBO(220, 90, 108, 1);
  static const up = Color.fromRGBO(83, 170, 232, 1);
  static const down = Color.fromRGBO(154, 85, 215, 1);
}

extension SwipeDirecionX on SwipeDirection {
  Color get color {
    switch (this) {
      case SwipeDirection.right:
        return const Color.fromRGBO(70, 195, 120, 1);
      case SwipeDirection.left:
        return const Color.fromRGBO(220, 90, 108, 1);
      case SwipeDirection.up:
        return const Color.fromRGBO(83, 170, 232, 1);
      case SwipeDirection.down:
        return const Color.fromRGBO(154, 85, 215, 1);
    }
  }
}
