import 'dart:math' as math;

import 'package:flutter/material.dart';

const _likeColor = Color.fromRGBO(70, 195, 120, 1);
const _nopeColor = Color.fromRGBO(220, 90, 108, 1);
const _labelAngle = math.pi / 2 * 0.2;

enum CardLabelType {
  like,
  nope,
}

extension CardLabelTypeConfig on CardLabelType {
  bool get _isLike => this == CardLabelType.like;

  double preferredOpacity(double amount) {
    final amountAbs = amount.abs();
    return _isLike
        ? amount < 0
            ? 0
            // ラベルの色が濃いのにカードが戻るとムカつく。
            : math.min(amountAbs * 0.8, 1)
        : amount > 0
            ? 0
            : math.min(amountAbs * 0.8, 1);
  }
}

class CardLabel extends StatelessWidget {
  const CardLabel._({
    @required this.color,
    @required this.label,
    @required this.angle,
    @required this.alignment,
    Key key,
  }) : super(key: key);

  factory CardLabel.like() {
    // TODO(heavenOSK): Implement with Extension.
    return const CardLabel._(
      color: _likeColor,
      label: 'LIKE',
      angle: -_labelAngle,
      // When user swipes right, user can see this label.
      alignment: Alignment.topLeft,
    );
  }

  factory CardLabel.nope() {
    // TODO(heavenOSK): Implement with Extension.
    return const CardLabel._(
      color: _nopeColor,
      label: 'NOPE',
      angle: _labelAngle,
      alignment: Alignment.topRight,
    );
  }

  final Color color;
  final String label;
  final double angle;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 12,
      ),
      child: Transform.rotate(
        angle: angle,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: color,
              width: 4,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
              color: color,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
