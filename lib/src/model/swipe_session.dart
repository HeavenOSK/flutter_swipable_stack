part of '../swipable_stack.dart';

const double _fingerHeight = 50;

/// The information to record swiping position for [SwipableStack].
class _SwipeSession {
  const _SwipeSession({
    required this.startPosition,
    required this.currentPosition,
    required this.localPosition,
  });

  factory _SwipeSession.notMoving() {
    return const _SwipeSession(
      startPosition: Offset.zero,
      currentPosition: Offset.zero,
      localPosition: Offset.zero,
    );
  }

  /// The start point of swipe action.
  final Offset startPosition;

  /// The current point of swipe action.
  final Offset currentPosition;

  /// The point which user is touching in the component.
  final Offset localPosition;

  @override
  bool operator ==(Object other) =>
      other is _SwipeSession &&
      startPosition == other.startPosition &&
      currentPosition == other.currentPosition &&
      localPosition == other.localPosition;

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      startPosition.hashCode ^
      currentPosition.hashCode ^
      localPosition.hashCode;

  @override
  String toString() => '$_SwipeSession('
      'startPosition:$startPosition,'
      'currentPosition:$currentPosition,'
      'localPosition:$localPosition'
      ')';

  _SwipeSession copyWith({
    Offset? startPosition,
    Offset? currentPosition,
    Offset? localPosition,
  }) =>
      _SwipeSession(
        startPosition: startPosition ?? this.startPosition,
        currentPosition: currentPosition ?? this.currentPosition,
        localPosition: localPosition ?? this.localPosition,
      );

  /// Difference offset from [startPosition] to [currentPosition] .
  Offset get difference {
    return currentPosition - startPosition;
  }

  /// Adjusted [localPosition] for user's finger.
  Offset? get localFingerPosition {
    return localPosition + const Offset(0, -_fingerHeight);
  }
}
