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

class SwipableStack extends StatefulWidget {
  SwipableStack({
    required this.builder,
    this.controller,
    this.onSwipeCompleted,
    this.onWillMoveNext,
    this.overlayBuilder,
    this.itemCount,
  }) : super(key: controller?.swipableStackStateKey);

  final IndexedWidgetBuilder builder;
  final SwipableStackController? controller;
  final SwipeCompletionCallback? onSwipeCompleted;
  final OnWillMoveNext? onWillMoveNext;
  final SwipableStackOverlayBuilder? overlayBuilder;
  final int? itemCount;

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

  Animation<Offset> _cancelAnimation() {
    return Tween<Offset>(
      begin: _sessionState.currentPosition,
      end: _sessionState.startPosition,
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

  bool get _canSwipeStart =>
      !_animating ||
      (_swipeCancelAnimationController.animating &&
          _swipeCancelAnimationController.value < 0.1);

  int _currentIndex = 0;

  static const double _defaultSwipeThreshold = 0.44;

  var _sessionState = const SwipeSessionState();

  bool get _allowMoveNext {
    final isDirectionRight = _sessionState.difference.dx > 0;
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

      final overlay = widget.overlayBuilder?.call(
        _sessionState.differenceToAlignment(
          areaConstraints: constraints,
          swipeThreshold: _defaultSwipeThreshold,
        ),
      );
      if (overlay != null) {
        positionedCards.add(
          SwipablePositioned.overlay(
            sessionState: _sessionState,
            areaConstraints: constraints,
            child: overlay,
          ),
        );
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
      state: _sessionState,
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
            _sessionState = _sessionState.copyWith(
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
            _sessionState = _sessionState.copyWith(
              localPosition: _sessionState.localPosition ?? d.localPosition,
              startPosition: _sessionState.startPosition ?? d.globalPosition,
              currentPosition: d.globalPosition,
            );
          });
        },
        onPanEnd: (d) {
          if (_animating) {
            return;
          }
          final shouldCancel = (_sessionState.difference.dx.abs()) <=
              constraints.maxWidth * (_defaultSwipeThreshold / 2);

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
    setState(() {
      _sessionState = _sessionState.copyWith(
        currentPosition: positionAnimation.value,
      );
    });
  }

  void _cancelSwipe() {
    final cancelAnimation = _cancelAnimation();
    void _animate() {
      _animatePosition(cancelAnimation);
    }

    cancelAnimation.addListener(_animate);
    _swipeCancelAnimationController.forward(from: 0).then(
      (_) {
        cancelAnimation.removeListener(_animate);
        setState(() {
          _sessionState = const SwipeSessionState();
        });
      },
    );
  }

  /// This method not calls [SwipableStack.onWillMoveNext].
  void next(SwipeDirection swipeDirection) {
    if (!_canSwipeStart) {
      return;
    }
    _sessionState = _sessionState.copyWith(
      startPosition: Offset.zero,
      currentPosition: Offset.zero,
      localPosition: Offset.zero,
    );

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
          _sessionState = const SwipeSessionState();
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
    return distance * rate;
  }

  void _swipeNext() {
    final isDirectionRight = _sessionState.difference.dx > 0;
    final swipeDirection =
        isDirectionRight ? SwipeDirection.right : SwipeDirection.left;

    final startPosition = _sessionState.currentPosition;
    if (startPosition == null) {
      return;
    }

    final animation = _swipeAnimation(
      startPosition: startPosition,
      endPosition: startPosition +
          _calculateSwipeDistance(
            distance: _sessionState.difference,
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
          _sessionState = const SwipeSessionState();
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
