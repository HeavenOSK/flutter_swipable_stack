part of '../swipable_stack.dart';

class _SwipeRatePerThreshold {
  _SwipeRatePerThreshold({
    required this.direction,
    required this.rate,
  }) : assert(rate >= 0);

  final SwipeDirection direction;
  final double rate;
}

extension _DirectionCheck on SwipeDirection {
  double clampSwipeRate(double rate) {
    switch (this) {
      case SwipeDirection.left:
        return rate.clamp(double.negativeInfinity, 0);
      case SwipeDirection.right:
        return rate.clamp(0, double.infinity);
      case SwipeDirection.up:
        return rate.clamp(double.negativeInfinity, 0);
      case SwipeDirection.down:
        return rate.clamp(0, double.infinity);
    }
  }
}

extension _SwipableStackPositionX on _SwipableStackPosition {
  _SwipeRatePerThreshold? swipeDirectionRate({
    required BoxConstraints constraints,
    required double horizontalSwipeThreshold,
    required double verticalSwipeThreshold,
    required Set<SwipeDirection> detectableDirections,
  }) {
    final horizontalRate =
        (difference.dx / constraints.maxWidth) / (horizontalSwipeThreshold / 2);
    final verticalRate =
        (difference.dy / constraints.maxHeight) / (verticalSwipeThreshold / 2);

    _SwipeRatePerThreshold? horizontalRatePerThreshold() {
      final filteredDirs = [SwipeDirection.left, SwipeDirection.right]
          .where(detectableDirections.contains);
      if (filteredDirs.isEmpty) {
        return null;
      }
      if (filteredDirs.length == 2) {
        return _SwipeRatePerThreshold(
          direction:
              difference.dx >= 0 ? SwipeDirection.right : SwipeDirection.left,
          rate: horizontalRate.abs(),
        );
      }
      final dir = filteredDirs.first;
      return _SwipeRatePerThreshold(
        direction: dir,
        rate: dir.clampSwipeRate(horizontalRate).abs(),
      );
    }

    _SwipeRatePerThreshold? verticalRatePerThreshold() {
      final filteredDirs = [SwipeDirection.up, SwipeDirection.down]
          .where(detectableDirections.contains);
      if (filteredDirs.isEmpty) {
        return null;
      }
      if (filteredDirs.length == 2) {
        return _SwipeRatePerThreshold(
          direction:
              difference.dy >= 0 ? SwipeDirection.down : SwipeDirection.up,
          rate: verticalRate.abs(),
        );
      }
      final dir = filteredDirs.first;
      return _SwipeRatePerThreshold(
        direction: dir,
        rate: dir.clampSwipeRate(verticalRate).abs(),
      );
    }

    final rateList = [
      verticalRatePerThreshold(),
      horizontalRatePerThreshold(),
    ].whereType<_SwipeRatePerThreshold>().toList();
    if (rateList.isEmpty) {
      return null;
    }
    return rateList.length == 1 || rateList[0].rate > rateList[1].rate
        ? rateList[0]
        : rateList[1];
  }

  SwipeDirection? swipeAssistDirection({
    required BoxConstraints constraints,
    required double horizontalSwipeThreshold,
    required double verticalSwipeThreshold,
    required Set<SwipeDirection> detectableDirections,
  }) {
    final directionRate = swipeDirectionRate(
      constraints: constraints,
      horizontalSwipeThreshold: horizontalSwipeThreshold,
      verticalSwipeThreshold: verticalSwipeThreshold,
      detectableDirections: detectableDirections,
    );
    if (directionRate == null) {
      return null;
    }
    if (directionRate.rate < 1) {
      return null;
    } else {
      return directionRate.direction;
    }
  }
}
