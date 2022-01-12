part of '../swipable_stack.dart';

class _SwipeRatePerThreshold {
  _SwipeRatePerThreshold({
    required this.direction,
    required this.rate,
  }) : assert(rate >= 0);

  final SwipeDirection direction;
  final double rate;
}

extension _SwipableStackPositionX on _SwipableStackPosition {
  _SwipeRatePerThreshold swipeDirectionRate({
    required BoxConstraints constraints,
    required double horizontalSwipeThreshold,
    required double verticalSwipeThreshold,
    required Iterable<SwipeDirection> allowedDirections,
  }) {
    final horizontalRate = (difference.dx.abs() / constraints.maxWidth) /
        (horizontalSwipeThreshold / 2);
    final verticalRate = (difference.dy.abs() / constraints.maxHeight) /
        (verticalSwipeThreshold / 2);
    final horizontalRateGreater = horizontalRate >= verticalRate;
    final horizontal = _SwipeRatePerThreshold(
      direction:
          difference.dx >= 0 ? SwipeDirection.right : SwipeDirection.left,
      rate: horizontalRate,
    );
    final vertical = _SwipeRatePerThreshold(
      direction: difference.dy >= 0 ? SwipeDirection.down : SwipeDirection.up,
      rate: verticalRate,
    );
    final primary = horizontalRateGreater ? horizontal : vertical;
    final secondary = horizontalRateGreater ? vertical : horizontal;
    if (allowedDirections.contains(primary.direction)) return primary;
    if (allowedDirections.contains(secondary.direction)) return secondary;
    return primary;
  }

  SwipeDirection? swipeAssistDirection({
    required BoxConstraints constraints,
    required double horizontalSwipeThreshold,
    required double verticalSwipeThreshold,
    required Iterable<SwipeDirection> allowedDirections,
  }) {
    final directionRate = swipeDirectionRate(
      constraints: constraints,
      horizontalSwipeThreshold: horizontalSwipeThreshold,
      verticalSwipeThreshold: verticalSwipeThreshold,
      allowedDirections: allowedDirections,
    );
    if (directionRate.rate < 1) {
      return null;
    } else {
      return directionRate.direction;
    }
  }
}
