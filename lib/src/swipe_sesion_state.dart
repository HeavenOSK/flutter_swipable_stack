import 'package:flutter/material.dart';

const double _fingerHeight = 50;

extension SwipeSessionStateX on SwipeSessionState {
  Offset get difference {
    return currentPosition - startPosition;
  }

  Alignment differenceToAlignment({
    required BoxConstraints areaConstraints,
    required double swipeThreshold,
  }) =>
      Alignment(
        difference.dx / (areaConstraints.maxWidth / 2),
        difference.dy / (areaConstraints.maxHeight / 2),
      ) /
      swipeThreshold;

  Offset? get localFingerPosition {
    return localPosition + const Offset(0, -_fingerHeight);
  }
}

class SwipeSessionState {
  const SwipeSessionState({
    required this.startPosition,
    required this.currentPosition,
    required this.localPosition,
  });

  factory SwipeSessionState.notMoving() {
    return const SwipeSessionState(
      startPosition: Offset.zero,
      currentPosition: Offset.zero,
      localPosition: Offset.zero,
    );
  }

  final Offset startPosition;
  final Offset currentPosition;
  final Offset localPosition;

  @override
  bool operator ==(Object other) =>
      other is SwipeSessionState &&
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
  String toString() => '$SwipeSessionState('
      'startPosition:$startPosition,'
      'currentPosition:$currentPosition,'
      'localPosition:$localPosition'
      ')';

  SwipeSessionState copyWith({
    Offset? startPosition,
    Offset? currentPosition,
    Offset? localPosition,
  }) =>
      SwipeSessionState(
        startPosition: startPosition ?? this.startPosition,
        currentPosition: currentPosition ?? this.currentPosition,
        localPosition: localPosition ?? this.localPosition,
      );
}
