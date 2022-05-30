part of '../swipable_stack.dart';

/// The information to record swiping position for [SwipableStack].
class _SwipableStackPosition {
  const _SwipableStackPosition({
    required this.start,
    required this.real,
    required this.realLocal,
    required this.animationValue,
  });

  factory _SwipableStackPosition.notMoving() {
    return const _SwipableStackPosition(
      start: Offset.zero,
      real: Offset.zero,
      realLocal: Offset.zero,
      animationValue: 1,
    );
  }

  factory _SwipableStackPosition.readyToSwipeAnimation({
    required SwipeDirection direction,
    required BoxConstraints areaConstraints,
  }) {
    Offset localPosition;
    switch (direction) {
      case SwipeDirection.left:
        localPosition = Offset(
          areaConstraints.maxWidth * 0.8,
          areaConstraints.maxHeight * 0.4,
        );
        break;
      case SwipeDirection.right:
        localPosition = Offset(
          areaConstraints.maxWidth * 0.2,
          areaConstraints.maxHeight * 0.4,
        );
        break;
      case SwipeDirection.up:
        localPosition = Offset(
          areaConstraints.maxWidth / 2,
          areaConstraints.maxHeight,
        );
        break;
      case SwipeDirection.down:
        localPosition = Offset(
          areaConstraints.maxWidth / 2,
          0,
        );
        break;
    }

    return _SwipableStackPosition(
      start: Offset.zero,
      real: Offset.zero,
      realLocal: localPosition,
      animationValue: 1,
    );
  }

  /// The value of _dragStartAnimation.
  final double animationValue;

  /// The start point of swipe action.
  final Offset start;

  /// The current point of swipe action.
  Offset get current => start + (real - start) * animationValue;

  /// The point which user is touching.
  final Offset real;

  /// The local point of swipe action.
  Offset get local => realLocal * animationValue;

  /// The point which user is touching in the component.
  final Offset realLocal;

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
      'realPosition:$real,'
      'localPosition:$local,'
      'realLocalPosition:$realLocal'
      ')';

  _SwipableStackPosition copyWith({
    Offset? startPosition,
    Offset? realPosition,
    Offset? realLocalPosition,
    double? animationValue,
  }) =>
      _SwipableStackPosition(
        start: startPosition ?? start,
        real: realPosition ?? real,
        realLocal: realLocalPosition ?? realLocal,
        animationValue: animationValue ?? this.animationValue,
      );

  /// Difference offset from [start] to [current] .
  Offset get difference {
    return current - start;
  }
}
