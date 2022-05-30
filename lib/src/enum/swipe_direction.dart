part of '../swipable_stack.dart';

/// The type of Action to use in [SwipableStack].
enum SwipeDirection {
  left(Offset(-1, 0)),
  right(Offset(1, 0)),
  up(Offset(0, -1)),
  down(Offset(0, 1));

  const SwipeDirection(this.defaultOffset);
  final Offset defaultOffset;
}

extension _SwipeDirectionX on SwipeDirection {
  bool get isHorizontal =>
      this == SwipeDirection.right || this == SwipeDirection.left;
}
