import 'package:flutter/material.dart';

const double _fingerHeight = 50;

class SwipeSession {
  const SwipeSession({
    required this.startPosition,
    required this.currentPosition,
    required this.localPosition,
  });

  factory SwipeSession.notMoving() {
    return const SwipeSession(
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
      other is SwipeSession &&
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
  String toString() => '$SwipeSession('
      'startPosition:$startPosition,'
      'currentPosition:$currentPosition,'
      'localPosition:$localPosition'
      ')';

  SwipeSession copyWith({
    Offset? startPosition,
    Offset? currentPosition,
    Offset? localPosition,
  }) =>
      SwipeSession(
        startPosition: startPosition ?? this.startPosition,
        currentPosition: currentPosition ?? this.currentPosition,
        localPosition: localPosition ?? this.localPosition,
      );

  Offset get difference {
    return currentPosition - startPosition;
  }

  Offset? get localFingerPosition {
    return localPosition + const Offset(0, -_fingerHeight);
  }
}
