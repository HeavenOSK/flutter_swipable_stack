import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'swipable_positioned.dart';
import 'swipable_stack_controller.dart';
import 'swipe_rate_per_threshold.dart';
import 'swipe_session_state.dart';

enum SwipeDirection {
  left,
  right,
  up,
  down,
}

extension _SwipeDirectionX on SwipeDirection {
  Offset get _defaultOffset {
    switch (this) {
      case SwipeDirection.left:
        return const Offset(-1, 0);
      case SwipeDirection.right:
        return const Offset(1, 0);
      case SwipeDirection.up:
        return const Offset(0, -1);
      case SwipeDirection.down:
        return const Offset(0, 1);
    }
  }

  bool get isHorizontal =>
      this == SwipeDirection.right || this == SwipeDirection.left;
}

extension _AnimationControllerX on AnimationController {
  bool get animating =>
      status == AnimationStatus.forward || status == AnimationStatus.reverse;

  Animation<Offset> cancelAnimation({
    required Offset startPosition,
    required Offset currentPosition,
  }) {
    return Tween<Offset>(
      begin: currentPosition,
      end: startPosition,
    ).animate(
      CurvedAnimation(
        parent: this,
        curve: const ElasticOutCurve(0.95),
      ),
    );
  }

  Animation<Offset> swipeAnimation({
    required Offset startPosition,
    required Offset endPosition,
  }) {
    return Tween<Offset>(
      begin: startPosition,
      end: endPosition,
    ).animate(
      CurvedAnimation(
        parent: this,
        curve: const Cubic(0.7, 1, 0.73, 1),
      ),
    );
  }
}

typedef SwipeCompletionCallback = void Function(
  int index,
  SwipeDirection direction,
);

typedef OnWillMoveNext = bool Function(
  int index,
  SwipeDirection direction,
);

typedef SwipableStackItemBuilder = Widget Function(
  BuildContext context,
  int index,
  BoxConstraints constraints,
);

typedef SwipableStackOverlayBuilder = Widget Function(
  BoxConstraints constraints,
  SwipeDirection direction,
  double valuePerThreshold,
);

extension _SwipeSessionStateX on SwipeSessionState {
  SwipeRatePerThreshold swipeDirectionRate({
    required BoxConstraints constraints,
    required double horizontalSwipeThreshold,
    required double verticalSwipeThreshold,
  }) {
    final horizontalRate = (difference.dx.abs() / constraints.maxWidth) /
        (horizontalSwipeThreshold / 2);
    final verticalRate = (difference.dy.abs() / constraints.maxHeight) /
        (verticalSwipeThreshold / 2);
    final horizontalRateGreater = horizontalRate >= verticalRate;
    if (horizontalRateGreater) {
      return SwipeRatePerThreshold(
        direction:
            difference.dx >= 0 ? SwipeDirection.right : SwipeDirection.left,
        rate: horizontalRate,
      );
    } else {
      return SwipeRatePerThreshold(
        direction: difference.dy >= 0 ? SwipeDirection.down : SwipeDirection.up,
        rate: verticalRate,
      );
    }
  }

  SwipeDirection? swipeAssistDirection({
    required BoxConstraints constraints,
    required double horizontalSwipeThreshold,
    required double verticalSwipeThreshold,
  }) {
    final directionRate = swipeDirectionRate(
      constraints: constraints,
      horizontalSwipeThreshold: horizontalSwipeThreshold,
      verticalSwipeThreshold: verticalSwipeThreshold,
    );
    if (directionRate.rate < 1) {
      return null;
    } else {
      return directionRate.direction;
    }
  }
}

class SwipableStack extends StatefulWidget {
  SwipableStack({
    required this.builder,
    SwipableStackController? controller,
    this.onSwipeCompleted,
    this.onWillMoveNext,
    this.overlayBuilder,
    this.horizontalSwipeThreshold = _defaultHorizontalSwipeThreshold,
    this.verticalSwipeThreshold = _defaultVerticalSwipeThreshold,
    this.itemCount,
    this.viewFraction = _defaultViewFraction,
  })  : controller = controller ?? SwipableStackController(),
        assert(0 <= viewFraction && viewFraction <= 1),
        assert(0 <= horizontalSwipeThreshold && horizontalSwipeThreshold <= 1),
        assert(0 <= verticalSwipeThreshold && verticalSwipeThreshold <= 1),
        assert(itemCount == null || itemCount > 0),
        super(key: controller?.swipableStackStateKey);

  final SwipableStackItemBuilder builder;
  final SwipableStackController controller;
  final SwipeCompletionCallback? onSwipeCompleted;
  final OnWillMoveNext? onWillMoveNext;
  final SwipableStackOverlayBuilder? overlayBuilder;
  final int? itemCount;
  final double viewFraction;
  final double horizontalSwipeThreshold;
  final double verticalSwipeThreshold;

  static const double _defaultHorizontalSwipeThreshold = 0.44;
  static const double _defaultVerticalSwipeThreshold = 0.32;
  static const double _defaultViewFraction = 0.92;

  static bool allowOnlyLeftAndRight(
    int index,
    SwipeDirection direction,
  ) =>
      direction == SwipeDirection.right || direction == SwipeDirection.left;

  static bool allowAllDirection(
    int index,
    SwipeDirection direction,
  ) =>
      true;

  @override
  SwipableStackState createState() => SwipableStackState();
}

class SwipableStackState extends State<SwipableStack>
    with TickerProviderStateMixin {
  late final AnimationController _swipeCancelAnimationController =
      AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  double _distanceToAssist({
    required BuildContext context,
    required Offset difference,
    required SwipeDirection swipeDirection,
  }) {
    final deviceSize = MediaQuery.of(context).size;
    if (swipeDirection.isHorizontal) {
      double _backMoveDistance({
        required double moveDistance,
        required double maxWidth,
        required double maxHeight,
      }) {
        final cardAngle = SwipablePositioned.calculateAngle(
          moveDistance,
          maxWidth,
        ).abs();
        return math.cos(math.pi / 2 - cardAngle) * maxHeight;
      }

      double _remainingDistance({
        required double moveDistance,
        required double maxWidth,
        required double maxHeight,
      }) {
        final backMoveDistance = _backMoveDistance(
          moveDistance: moveDistance,
          maxHeight: maxHeight,
          maxWidth: maxWidth,
        );
        final diff = maxWidth - (moveDistance - backMoveDistance);
        return diff < 1
            ? moveDistance
            : _remainingDistance(
                moveDistance: moveDistance + diff,
                maxWidth: maxWidth,
                maxHeight: maxHeight,
              );
      }

      final maxWidth = _areConstraints?.maxWidth ?? deviceSize.width;
      final maxHeight = _areConstraints?.maxHeight ?? deviceSize.height;
      final maxDistance = _remainingDistance(
        moveDistance: maxWidth,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
      final initialBackMoveDistance = _backMoveDistance(
        moveDistance: difference.dx.abs(),
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
      return maxDistance - difference.dx.abs() + initialBackMoveDistance;
    } else {
      return deviceSize.height - difference.dy.abs();
    }
  }

  Offset _offsetToAssist({
    required Offset difference,
    required BuildContext context,
    required SwipeDirection swipeDirection,
    required double distToAssist,
  }) {
    final isHorizontal = swipeDirection.isHorizontal;
    if (isHorizontal) {
      final adjustedHorizontally = Offset(difference.dx * 2, difference.dy);
      final absX = adjustedHorizontally.dx.abs();
      final rate = distToAssist / absX;
      return adjustedHorizontally * rate;
    } else {
      final adjustedVertically = Offset(difference.dx, difference.dy * 2);
      final absY = adjustedVertically.dy.abs();
      final rate = distToAssist / absY;
      return adjustedVertically * rate;
    }
  }

  AnimationController _swipeAssistController({
    required SwipeDirection swipeDirection,
    required Offset difference,
    required double distToAssist,
  }) {
    final pixelPerMilliseconds = swipeDirection.isHorizontal ? 1.25 : 2.0;

    return AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: math.min(distToAssist ~/ pixelPerMilliseconds, 500),
      ),
    );
  }

  int get currentIndex => widget.controller.currentIndex;

  set currentIndex(int newValue) {
    widget.controller.currentIndex = newValue;
  }

  bool get _animatingSwipeAssistController => _swipeController != null;
  AnimationController? _swipeController;

  SwipeSessionState? get currentSessionState =>
      widget.controller.currentSessionState;

  set currentSessionState(SwipeSessionState? newValue) {
    widget.controller.currentSessionState = newValue;
  }

  SwipeSessionState? get previousSessionState =>
      widget.controller.previousSessionState;

  set previousSessionState(SwipeSessionState? newValue) {
    widget.controller.previousSessionState = newValue;
  }

  BoxConstraints? _areConstraints;

  bool get _canRewind => previousSessionState != null && currentIndex > 0;

  void _listenController() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listenController);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _areConstraints = constraints;
        return Stack(
          children: _buildCards(
            context,
            constraints,
          ),
        );
      },
    );
  }

  List<Widget> _buildCards(BuildContext context, BoxConstraints constraints) {
    final cards = <Widget>[];
    for (var index = currentIndex;
        index <
            math.min(currentIndex + 3, widget.itemCount ?? currentIndex + 3);
        index++) {
      cards.add(
        widget.builder(
          context,
          index,
          constraints,
        ),
      );
    }
    if (cards.isEmpty) {
      return [];
    } else {
      final positionedCards = List<Widget>.generate(
        cards.length,
        (index) => _buildCard(
          index: index,
          child: cards[index],
          constraints: constraints,
        ),
      ).reversed.toList();
      final swipeDirectionRate = currentSessionState?.swipeDirectionRate(
        constraints: constraints,
        horizontalSwipeThreshold: widget.horizontalSwipeThreshold,
        verticalSwipeThreshold: widget.verticalSwipeThreshold,
      );

      if (swipeDirectionRate != null) {
        final overlay = widget.overlayBuilder?.call(
          constraints,
          swipeDirectionRate.direction,
          swipeDirectionRate.rate,
        );
        if (overlay != null) {
          final session = currentSessionState ?? SwipeSessionState.notMoving();
          positionedCards.add(
            SwipablePositioned.overlay(
              viewFraction: widget.viewFraction,
              sessionState: session,
              swipeDirectionRate: swipeDirectionRate,
              areaConstraints: constraints,
              child: overlay,
            ),
          );
        }
      }

      return positionedCards;
    }
  }

  Widget _buildCard({
    required int index,
    required Widget child,
    required BoxConstraints constraints,
  }) {
    final session = currentSessionState ?? SwipeSessionState.notMoving();
    return SwipablePositioned(
      key: child.key ?? ValueKey(currentIndex + index),
      state: session,
      index: index,
      viewFraction: widget.viewFraction,
      swipeDirectionRate: session.swipeDirectionRate(
        constraints: constraints,
        horizontalSwipeThreshold: widget.horizontalSwipeThreshold,
        verticalSwipeThreshold: widget.verticalSwipeThreshold,
      ),
      areaConstraints: constraints,
      child: GestureDetector(
        key: child.key,
        onPanStart: (d) {
          if (_animatingSwipeAssistController) {
            return;
          }

          if (_swipeCancelAnimationController.animating) {
            _swipeCancelAnimationController
              ..stop()
              ..reset();
          }
          widget.controller.previousSessionState;

          currentSessionState = SwipeSessionState(
            localPosition: d.localPosition,
            startPosition: d.globalPosition,
            currentPosition: d.globalPosition,
          );
        },
        onPanUpdate: (d) {
          if (_animatingSwipeAssistController) {
            return;
          }
          if (_swipeCancelAnimationController.animating) {
            _swipeCancelAnimationController
              ..stop()
              ..reset();
          }
          final updated = currentSessionState?.copyWith(
            currentPosition: d.globalPosition,
          );
          currentSessionState = updated ??
              SwipeSessionState(
                localPosition: d.localPosition,
                startPosition: d.globalPosition,
                currentPosition: d.globalPosition,
              );
        },
        onPanEnd: (d) {
          if (_animatingSwipeAssistController) {
            return;
          }
          final swipeAssistDirection =
              currentSessionState?.swipeAssistDirection(
            constraints: constraints,
            horizontalSwipeThreshold: widget.horizontalSwipeThreshold,
            verticalSwipeThreshold: widget.verticalSwipeThreshold,
          );

          if (swipeAssistDirection == null) {
            _cancelSwipe();
            return;
          }
          final allowMoveNext = widget.onWillMoveNext?.call(
                currentIndex,
                swipeAssistDirection,
              ) ??
              true;
          if (!allowMoveNext) {
            _cancelSwipe();
            return;
          }
          _swipeNext(swipeAssistDirection);
        },
        child: child,
      ),
    );
  }

  void _animatePosition(Animation<Offset> positionAnimation) {
    final currentSession = currentSessionState;
    if (currentSession == null) {
      return;
    }
    currentSessionState = currentSession.copyWith(
      currentPosition: positionAnimation.value,
    );
  }

  void rewind() {
    if (!_canRewind) {
      return;
    }

    setState(() {
      currentSessionState = previousSessionState;
      currentIndex -= 1;
    });
    final previousPosition = previousSessionState?.currentPosition;
    final startPosition = previousSessionState?.startPosition;
    if (previousPosition == null || startPosition == null) {
      return;
    }

    final cancelAnimation = _swipeCancelAnimationController.cancelAnimation(
      startPosition: startPosition,
      currentPosition: previousPosition,
    );
    void _animate() {
      _animatePosition(cancelAnimation);
    }

    cancelAnimation.addListener(_animate);
    _swipeCancelAnimationController.forward(from: 0).then(
      (_) {
        cancelAnimation.removeListener(_animate);
        previousSessionState = null;
        currentSessionState = null;
      },
    ).catchError((dynamic c) {
      cancelAnimation.removeListener(_animate);
      previousSessionState = null;
      currentSessionState = null;
    });
  }

  void _cancelSwipe() {
    final currentSession = currentSessionState;
    if (currentSession == null) {
      return;
    }
    final cancelAnimation = _swipeCancelAnimationController.cancelAnimation(
      startPosition: currentSession.startPosition,
      currentPosition: currentSession.currentPosition,
    );
    void _animate() {
      _animatePosition(cancelAnimation);
    }

    cancelAnimation.addListener(_animate);
    _swipeCancelAnimationController.forward(from: 0).then(
      (_) {
        cancelAnimation.removeListener(_animate);

        currentSessionState = null;
      },
    ).catchError((dynamic c) {
      cancelAnimation.removeListener(_animate);

      currentSessionState = null;
    });
  }

  void _swipeNext(SwipeDirection swipeDirection) {
    final currentSession = currentSessionState;
    if (currentSession == null) {
      return;
    }
    if (_animatingSwipeAssistController) {
      return;
    }
    final distToAssist = _distanceToAssist(
      swipeDirection: swipeDirection,
      context: context,
      difference: currentSession.difference,
    );
    _swipeController = _swipeAssistController(
      distToAssist: distToAssist,
      swipeDirection: swipeDirection,
      difference: currentSession.difference,
    );

    final animation = _swipeController?.swipeAnimation(
      startPosition: currentSession.currentPosition,
      endPosition: currentSession.currentPosition +
          _offsetToAssist(
            distToAssist: distToAssist,
            difference: currentSession.difference,
            context: context,
            swipeDirection: swipeDirection,
          ),
    );
    if (animation == null) {
      return;
    }
    void animate() {
      _animatePosition(animation);
    }

    animation.addListener(animate);
    _swipeController?.forward().then(
      (_) {
        animation.removeListener(animate);
        widget.onSwipeCompleted?.call(
          currentIndex,
          swipeDirection,
        );
        _swipeController?.dispose();
        _swipeController = null;
        previousSessionState = currentSessionState?.copyWith();
        currentIndex += 1;
        currentSessionState = null;
      },
    ).catchError((dynamic c) {
      animation.removeListener(animate);
      _swipeController?.dispose();
      _swipeController = null;
      currentSessionState = null;
    });
  }

  /// This method not calls [SwipableStack.onWillMoveNext].
  void next({
    required SwipeDirection swipeDirection,
    bool shouldCallCompletionCallback = true,
  }) {
    if (_animatingSwipeAssistController) {
      return;
    }
    final startPosition = SwipeSessionState.notMoving();
    currentSessionState = startPosition;
    final distToAssist = _distanceToAssist(
      swipeDirection: swipeDirection,
      context: context,
      difference: startPosition.difference,
    );
    _swipeController = _swipeAssistController(
      distToAssist: distToAssist,
      swipeDirection: swipeDirection,
      difference: startPosition.difference,
    );

    final animation = _swipeController?.swipeAnimation(
      startPosition: startPosition.currentPosition,
      endPosition: _offsetToAssist(
        distToAssist: distToAssist,
        difference: swipeDirection._defaultOffset,
        context: context,
        swipeDirection: swipeDirection,
      ),
    );
    if (animation == null) {
      return;
    }
    void animate() {
      _animatePosition(animation);
    }

    animation.addListener(animate);
    _swipeController?.forward().then(
      (_) {
        if (shouldCallCompletionCallback) {
          widget.onSwipeCompleted?.call(
            currentIndex,
            swipeDirection,
          );
        }
        animation.removeListener(animate);
        _swipeController?.dispose();
        _swipeController = null;
        previousSessionState = currentSessionState?.copyWith();
        currentIndex += 1;
        currentSessionState = null;
      },
    ).catchError((dynamic c) {
      animation.removeListener(animate);
      _swipeController?.dispose();
      _swipeController = null;
      currentSessionState = null;
    });
  }

  @override
  void dispose() {
    _swipeCancelAnimationController.dispose();
    _swipeController?.dispose();
    widget.controller.removeListener(_listenController);
    super.dispose();
  }
}
