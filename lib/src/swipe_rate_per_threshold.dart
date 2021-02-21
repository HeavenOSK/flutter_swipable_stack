import 'swipable_stack.dart';

class SwipeRatePerThreshold {
  SwipeRatePerThreshold({
    required this.direction,
    required this.rate,
  }) : assert(rate >= 0);

  final SwipeDirection direction;
  final double rate;
}
