import 'package:flutter/material.dart';

const double _fingerHeight = 50;

extension SwipeSessionStateX on SwipeSessionState {
  Offset get difference {
    if (currentPosition == null || startPosition == null) {
      return Offset.zero;
    }
    return (currentPosition ?? Offset.zero) - (startPosition ?? Offset.zero);
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
    return localPosition != null
        ? (localPosition ?? Offset.zero) + const Offset(0, -_fingerHeight)
        : null;
  }
}

class SwipeSessionState {
  const SwipeSessionState({
    this.startPosition,
    this.currentPosition,
    this.localPosition,
  });

  final Offset? startPosition;
  final Offset? currentPosition;
  final Offset? localPosition;

  @override
  bool operator ==(Object other) =>
      other is SwipeSessionState &&
      startPosition == other.startPosition &&
      currentPosition == other.currentPosition &&
      localPosition == other.localPosition;

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      (startPosition?.hashCode ?? null.hashCode) ^
      (currentPosition?.hashCode ?? null.hashCode) ^
      (localPosition?.hashCode ?? null.hashCode);

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
