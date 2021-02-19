import 'dart:math';

import 'package:flutter/material.dart';

import 'swipable_positioned.dart';
import 'swipable_stack_controller.dart';
import 'swipe_sesion_state.dart';

extension _Animating on AnimationController {
  bool get animating =>
      status == AnimationStatus.forward || status == AnimationStatus.reverse;
}

enum SwipeDirection {
  left,
  right,
}

extension _SwipeDirectionX on SwipeDirection {
  Offset maxMovingDistance(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    switch (this) {
      case SwipeDirection.left:
        return Offset(-deviceSize.width, 0) * 1.04;
      case SwipeDirection.right:
        return Offset(deviceSize.width, 0) * 1.04;
    }
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

typedef SwipableStackOverlayBuilder = Widget Function(
  Alignment alignmentPerThreshold,
);

// TODO(heavenOSK): Change Design
// Change SwipeSession to be nullable
// - SwipeSession is null
//   - user not touching
//   - don't have to move cards
// - SwipeSession is not null
//   - user not touching
//   - have to be ready to move cards
class SwipableStack extends StatefulWidget {
  SwipableStack({
    required this.builder,
    this.controller,
    this.onSwipeCompleted,
    this.onWillMoveNext,
    this.overlayBuilder,
    this.swipeThreshold = _defaultSwipeThreshold,
    this.itemCount,
  })  : assert(0 <= swipeThreshold && swipeThreshold <= 1),
        super(key: controller?.swipableStackStateKey);

  final IndexedWidgetBuilder builder;
  final SwipableStackController? controller;
  final SwipeCompletionCallback? onSwipeCompleted;
  final OnWillMoveNext? onWillMoveNext;
  final SwipableStackOverlayBuilder? overlayBuilder;
  final int? itemCount;
  final double swipeThreshold;

  static const double _defaultSwipeThreshold = 0.44;

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

  late final AnimationController _swipeAssistAnimationController =
      AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );

  Animation<Offset> _cancelAnimation({
    required Offset startPosition,
    required Offset currentPosition,
  }) {
    return Tween<Offset>(
      begin: currentPosition,
      end: startPosition,
    ).animate(
      CurvedAnimation(
        parent: _swipeCancelAnimationController,
        curve: const ElasticOutCurve(0.95),
      ),
    );
  }

  Animation<Offset> _swipeAnimation({
    required Offset startPosition,
    required Offset endPosition,
  }) {
    return Tween<Offset>(
      begin: startPosition,
      end: endPosition,
    ).animate(
      CurvedAnimation(
        parent: _swipeAssistAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  bool get _animating =>
      _swipeCancelAnimationController.animating ||
      _swipeAssistAnimationController.animating;

  bool get _canSwipeStart => !_swipeAssistAnimationController.animating;

  int _currentIndex = 0;

  SwipeSessionState? _sessionState;

  bool get _allowMoveNext {
    final difference = _sessionState?.difference;
    if (difference == null) {
      return false;
    }
    final isDirectionRight = difference.dx > 0;
    final swipeDirection =
        isDirectionRight ? SwipeDirection.right : SwipeDirection.left;
    return widget.onWillMoveNext?.call(
          _currentIndex,
          swipeDirection,
        ) ??
        true;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
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
    for (var index = _currentIndex;
        index < min(_currentIndex + 3, widget.itemCount ?? _currentIndex + 3);
        index++) {
      cards.add(
        widget.builder(
          context,
          index,
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
      final diffAlignment = _sessionState?.differenceToAlignment(
        areaConstraints: constraints,
        swipeThreshold: widget.swipeThreshold,
      );
      if (diffAlignment != null) {
        final overlay = widget.overlayBuilder?.call(
          diffAlignment,
        );
        if (overlay != null) {
          positionedCards.add(
            SwipablePositioned.overlay(
              sessionState: _sessionState ?? SwipeSessionState.notMoving(),
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
    return SwipablePositioned(
      state: _sessionState ?? SwipeSessionState.notMoving(),
      index: index,
      areaConstraints: constraints,
      child: GestureDetector(
        onPanStart: (d) {
          if (!_canSwipeStart) {
            return;
          }

          if (_swipeCancelAnimationController.animating) {
            _swipeCancelAnimationController
              ..stop()
              ..reset();
          }
          setState(() {
            _sessionState = SwipeSessionState(
              localPosition: d.localPosition,
              startPosition: d.globalPosition,
              currentPosition: d.globalPosition,
            );
          });
        },
        onPanUpdate: (d) {
          if (!_canSwipeStart) {
            return;
          }
          if (_swipeCancelAnimationController.animating) {
            _swipeCancelAnimationController
              ..stop()
              ..reset();
          }
          setState(() {
            final updated = _sessionState?.copyWith(
              currentPosition: d.globalPosition,
            );
            _sessionState = updated ??
                SwipeSessionState(
                  localPosition: d.localPosition,
                  startPosition: d.globalPosition,
                  currentPosition: d.globalPosition,
                );
          });
        },
        onPanEnd: (d) {
          if (_animating) {
            return;
          }
          final diff = _sessionState?.difference;
          if (diff == null) {
            return;
          }
          final shouldCancel = (diff.dx.abs()) <=
              constraints.maxWidth * (widget.swipeThreshold / 2);

          if (shouldCancel || !_allowMoveNext) {
            _cancelSwipe();
            return;
          }
          _swipeNext();
        },
        child: child,
      ),
    );
  }

  void _animatePosition(Animation<Offset> positionAnimation) {
    final currentSession = _sessionState;
    if (currentSession == null) {
      return;
    }
    setState(() {
      _sessionState = currentSession.copyWith(
        currentPosition: positionAnimation.value,
      );
    });
  }

  void _cancelSwipe() {
    final currentSession = _sessionState;
    if (currentSession == null) {
      return;
    }
    final cancelAnimation = _cancelAnimation(
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
        setState(() {
          _sessionState = null;
        });
      },
    );
  }

  /// This method not calls [SwipableStack.onWillMoveNext].
  void next(SwipeDirection swipeDirection) {
    if (!_canSwipeStart) {
      return;
    }
    _sessionState = SwipeSessionState.notMoving();

    final animation = _swipeAnimation(
      startPosition: Offset.zero,
      endPosition: swipeDirection.maxMovingDistance(context),
    );
    void _animate() {
      _animatePosition(animation);
    }

    animation.addListener(_animate);
    _swipeAssistAnimationController.forward(from: 0).then(
      (_) {
        animation.removeListener(_animate);
        setState(() {
          _currentIndex += 1;
          _sessionState = null;
        });
      },
    );
  }

  Offset _calculateSwipeDistance({
    required Offset distance,
    required BuildContext context,
  }) {
    final deviceSize = MediaQuery.of(context).size;
    final absX = distance.dx.abs();
    final rate = (deviceSize.width - absX) / absX;
    return distance * rate * 2;
  }

  void _swipeNext() {
    final currentSession = _sessionState;
    if (currentSession == null) {
      return;
    }

    final isDirectionRight = currentSession.difference.dx > 0;
    final swipeDirection =
        isDirectionRight ? SwipeDirection.right : SwipeDirection.left;

    final animation = _swipeAnimation(
      startPosition: currentSession.currentPosition,
      endPosition: currentSession.currentPosition +
          _calculateSwipeDistance(
            distance: currentSession.difference,
            context: context,
          ),
    );
    void animate() {
      _animatePosition(animation);
    }

    animation.addListener(animate);
    _swipeAssistAnimationController.forward(from: 0).then(
      (_) {
        widget.onSwipeCompleted?.call(
          _currentIndex,
          swipeDirection,
        );
        animation.removeListener(animate);
        setState(() {
          _currentIndex += 1;
          _sessionState = null;
        });
      },
    );
  }

  @override
  void dispose() {
    _swipeCancelAnimationController.dispose();
    _swipeAssistAnimationController.dispose();
    super.dispose();
  }
}
