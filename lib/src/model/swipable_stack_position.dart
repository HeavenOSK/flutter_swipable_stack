part of '../swipable_stack.dart';

// const double _fingerHeight = 50;

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

  /// Adjusted [local] for user's finger.
  Offset? get localFingerPosition {
    return local + const Offset(0, -0);
  }
}
