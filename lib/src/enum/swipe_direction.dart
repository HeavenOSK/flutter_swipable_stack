part of '../swipable_stack.dart';

/// The type of Action to use in [SwipableStack].
enum SwipeDirection {
  left,
  right,
  up,
  down,
}

extension _SwipeDirectionX on SwipeDirection {
  Offset get defaultOffset {
    switch (this) {
      case SwipeDirection.left:
        return const Offset(-1, 0);
      case SwipeDirection.right:
        return const Offset(1, 0);
      case SwipeDirection.up:
        return const Offset(0, -1);
      case SwipeDirection.down:
        return const Offset(0, 1);
    }
  }

  bool get isHorizontal =>
      this == SwipeDirection.right || this == SwipeDirection.left;
}
