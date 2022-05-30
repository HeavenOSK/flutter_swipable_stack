import 'dart:math' as math;

import 'package:example/widgets/card_label.dart';
import 'package:flutter/material.dart';
import 'package:swipable_stack/swipable_stack.dart';

class CardOverlay extends StatelessWidget {
  const CardOverlay({
    required this.direction,
    required this.swipeProgress,
    super.key,
  });
  final SwipeDirection direction;
  final double swipeProgress;

  @override
  Widget build(BuildContext context) {
    final opacity = math.min<double>(swipeProgress, 1);

    final isRight = direction == SwipeDirection.right;
    final isLeft = direction == SwipeDirection.left;
    final isUp = direction == SwipeDirection.up;
    final isDown = direction == SwipeDirection.down;
    return Stack(
      children: [
        Opacity(
          opacity: isRight ? opacity : 0,
          child: CardLabel.right(),
        ),
        Opacity(
          opacity: isLeft ? opacity : 0,
          child: CardLabel.left(),
        ),
        Opacity(
          opacity: isUp ? opacity : 0,
          child: CardLabel.up(),
        ),
        Opacity(
          opacity: isDown ? opacity : 0,
          child: CardLabel.down(),
        ),
      ],
    );
  }
}
