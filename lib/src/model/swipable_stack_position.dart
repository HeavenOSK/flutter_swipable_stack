part of '../swipable_stack.dart';

/// The information to record swiping position for [SwipableStack].
class _SwipableStackPosition {
  const _SwipableStackPosition({
    required this.start,
    required this.current,
    required this.local,
  });

  factory _SwipableStackPosition.notMoving() {
    return const _SwipableStackPosition(
      start: Offset.zero,
      current: Offset.zero,
      local: Offset.zero,
    );
  }

  factory _SwipableStackPosition.readyToSwipeAnimation({
    required SwipeDirection direction,
    required BoxConstraints areaConstraints,
  }) {
    Offset localPosition() {
      switch (direction) {
        case SwipeDirection.left:
          return Offset(
            areaConstraints.maxWidth * 0.8,
            areaConstraints.maxHeight * 0.4,
          );
        case SwipeDirection.right:
          return Offset(
            areaConstraints.maxWidth * 0.2,
            areaConstraints.maxHeight * 0.4,
          );
        case SwipeDirection.up:
          return Offset(
            areaConstraints.maxWidth / 2,
            areaConstraints.maxHeight,
          );
        case SwipeDirection.down:
          return Offset(
            areaConstraints.maxWidth / 2,
            0,
          );
      }
    }

    return _SwipableStackPosition(
      start: Offset.zero,
      current: Offset.zero,
      local: localPosition(),
    );
  }

  /// The start point of swipe action.
  final Offset start;

  /// The current point of swipe action.
  final Offset current;

  /// The point which user is touching in the component.
  final Offset local;

  @override
  bool operator ==(Object other) =>
      other is _SwipableStackPosition &&
      start == other.start &&
      current == other.current &&
      local == other.local;

  @override
  int get hashCode =>
      runtimeType.hashCode ^ start.hashCode ^ current.hashCode ^ local.hashCode;

  @override
  String toString() => '$_SwipableStackPosition('
      'startPosition:$start,'
      'currentPosition:$current,'
      'localPosition:$local'
      ')';

  _SwipableStackPosition copyWith({
    Offset? startPosition,
    Offset? currentPosition,
    Offset? localPosition,
  }) =>
      _SwipableStackPosition(
        start: startPosition ?? start,
        current: currentPosition ?? current,
        local: localPosition ?? local,
      );

  /// Difference offset from [start] to [current] .
  Offset get difference {
    return current - start;
  }
}
