part of '../swipable_stack.dart';

/// Callback called when the Swipe is completed.
typedef SwipeCompletionCallback = void Function(
  int index,
  SwipeDirection direction,
);

/// Callback called just before launching the Swipe action.
typedef OnWillMoveNext = bool Function(
  int index,
  SwipeDirection swipeDirection,
);

/// Builder for items to be displayed in [SwipableStack].
typedef SwipableStackItemBuilder = Widget Function(
  BuildContext context,
  int index,
  int stackIndex,
  BoxConstraints constraints,
  SwipeDirection direction,
  double swipeProgress,
);

/// Builder for displaying an overlay on the most foreground card.
typedef SwipableStackOverlayBuilder = Widget Function(
  BuildContext context,
  BoxConstraints constraints,
  int index,
  SwipeDirection direction,
  double swipeProgress,
);
