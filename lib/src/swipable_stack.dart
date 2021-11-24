import 'dart:math' as math;

import 'package:flutter/material.dart';

part 'animation/animation.dart';
part 'callback/callbacks.dart';
part 'enum/swipe_anchor.dart';
part 'enum/swipe_direction.dart';
part 'model/swipe_rate_per_threshold.dart';
part 'model/swipe_session.dart';
part 'swipable_stack_controller.dart';

/// A widget for stacking cards, which users can swipe horizontally and
/// vertically with beautiful animations.
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
    this.swipeAssistDuration = _defaultSwipeAssistDuration,
    this.stackClipBehaviour = _defaultStackClipBehaviour,
    this.allowVerticalSwipe = true,
    this.swipeAnchor = SwipeAnchor.top,
  })  : controller = controller ?? SwipableStackController(),
        assert(0 <= viewFraction && viewFraction <= 1),
        assert(0 <= horizontalSwipeThreshold && horizontalSwipeThreshold <= 1),
        assert(0 <= verticalSwipeThreshold && verticalSwipeThreshold <= 1),
        assert(itemCount == null || itemCount >= 0),
        super(key: controller?._swipableStackStateKey);

  /// Builder for items to be displayed in [SwipableStack].
  final SwipableStackItemBuilder builder;

  /// An object to manipulate the [SwipableStack].
  final SwipableStackController controller;

  /// Callback called when the Swipe is completed.
  final SwipeCompletionCallback? onSwipeCompleted;

  /// Callback called just before launching the Swipe action.
  ///
  /// If this Callback returns false, the action will be canceled.
  final OnWillMoveNext? onWillMoveNext;

  /// Builder for displaying an overlay on the most foreground card.
  final SwipableStackOverlayBuilder? overlayBuilder;

  /// The count of items to display.
  final int? itemCount;

  /// The second child size rate.
  final double viewFraction;

  /// The threshold for horizontal swipes.
  final double horizontalSwipeThreshold;

  /// The threshold for vertical swipes.
  final double verticalSwipeThreshold;

  /// How fast should the widget be swiped out of the screen when letting go?
  /// The faster you set this, the faster you're able to swipe another Widget
  /// of your stack.
  final Duration swipeAssistDuration;

  final Clip stackClipBehaviour;

  /// Allow vertical swipe
  final bool allowVerticalSwipe;

  /// Where should the card be anchored on during swipe rotation
  final SwipeAnchor swipeAnchor;

  static const double _defaultHorizontalSwipeThreshold = 0.44;
  static const double _defaultVerticalSwipeThreshold = 0.32;
  static const double _defaultViewFraction = 0.92;

  static const _defaultRewindDuration = Duration(milliseconds: 650);

  static const _defaultSwipeAssistDuration = Duration(milliseconds: 650);

  static const _defaultStackClipBehaviour = Clip.hardEdge;

  @override
  _SwipableStackState createState() => _SwipableStackState();
}

class _SwipableStackState extends State<SwipableStack>
    with TickerProviderStateMixin {
  late final AnimationController _swipeCancelAnimationController =
      AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  late final AnimationController _rewindAnimationController =
      AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  late final AnimationController _swipeAnimationController =
      AnimationController(
    vsync: this,
  );

  late final AnimationController _swipeAssistController = AnimationController(
    vsync: this,
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
        final cardAngle = _SwipablePositioned.calculateAngle(
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
      return maxDistance - difference.dx.abs();
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

  Duration _getSwipeAssistDuration({
    required SwipeDirection swipeDirection,
    required Offset difference,
    required double distToAssist,
  }) {
    final pixelPerMilliseconds = swipeDirection.isHorizontal ? 1.25 : 2.0;

    return Duration(
      milliseconds: math.min(
        distToAssist ~/ pixelPerMilliseconds,
        widget.swipeAssistDuration.inMilliseconds,
      ),
    );
  }

  Duration _getSwipeAnimationDuration({
    required SwipeDirection swipeDirection,
    required Offset difference,
    required double distToAssist,
  }) {
    final pixelPerMilliseconds = swipeDirection.isHorizontal ? 0.78 : 1.25;

    return Duration(
      milliseconds: math.min(distToAssist ~/ pixelPerMilliseconds, 650),
    );
  }

  /// The index of the item which displays front.
  int get _currentIndex => widget.controller.currentIndex;

  bool get canSwipe =>
      !_swipeAssistController.animating &&
      !_swipeAnimationController.animating &&
      !_rewindAnimationController.animating;

  bool get canAnimationStart =>
      !_swipeAssistController.animating &&
      !_swipeAnimationController.animating &&
      !_swipeCancelAnimationController.animating &&
      !_rewindAnimationController.animating;

  /// The current session of swipe action.
  _SwipeSession? get _currentSession => widget.controller.currentSession;

  BoxConstraints? _areConstraints;

  void _listenController() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listenController);
  }

  @override
  void didUpdateWidget(covariant SwipableStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemCount != widget.itemCount) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _assertLayout(constraints);
        _areConstraints = constraints;
        return Stack(
          clipBehavior: widget.stackClipBehaviour,
          children: _buildCards(
            context,
            constraints,
          ),
        );
      },
    );
  }

  void _assertLayout(BoxConstraints constraints) {
    assert(() {
      if (!constraints.hasBoundedHeight) {
        throw FlutterError('SwipableStack was given unbounded height.');
      }
      if (!constraints.hasBoundedWidth) {
        throw FlutterError('SwipableStack was given unbounded width.');
      }
      return true;
    }());
  }

  List<Widget> _buildCards(BuildContext context, BoxConstraints constraints) {
    final cards = <Widget>[];
    for (var index = _currentIndex;
        index <
            math.min(_currentIndex + 3, widget.itemCount ?? _currentIndex + 3);
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
      final swipeDirectionRate = _currentSession?.swipeDirectionRate(
        constraints: constraints,
        horizontalSwipeThreshold: widget.horizontalSwipeThreshold,
        verticalSwipeThreshold: widget.verticalSwipeThreshold,
      );

      if (swipeDirectionRate != null) {
        final overlay = widget.overlayBuilder?.call(
          context,
          constraints,
          _currentIndex,
          swipeDirectionRate.direction,
          swipeDirectionRate.rate,
        );
        if (overlay != null) {
          final session = _currentSession ?? _SwipeSession.notMoving();
          positionedCards.add(
            _SwipablePositioned.overlay(
              viewFraction: widget.viewFraction,
              session: session,
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
    final session = _currentSession ?? _SwipeSession.notMoving();
    return _SwipablePositioned(
      key: child.key ?? ValueKey(_currentIndex + index),
      session: session,
      index: index,
      viewFraction: widget.viewFraction,
      swipeAnchor: widget.swipeAnchor,
      swipeDirectionRate: session.swipeDirectionRate(
        constraints: constraints,
        horizontalSwipeThreshold: widget.horizontalSwipeThreshold,
        verticalSwipeThreshold: widget.verticalSwipeThreshold,
      ),
      areaConstraints: constraints,
      child: GestureDetector(
        key: child.key,
        onPanStart: (d) {
          if (!canSwipe) {
            return;
          }

          if (_swipeCancelAnimationController.animating) {
            _swipeCancelAnimationController
              ..stop()
              ..reset();
          }
          widget.controller._updateSwipe(
            _SwipeSession(
              localPosition: d.localPosition,
              startPosition: d.globalPosition,
              currentPosition: d.globalPosition,
            ),
          );
        },
        onPanUpdate: (d) {
          if (!canSwipe) {
            return;
          }
          if (_swipeCancelAnimationController.animating) {
            _swipeCancelAnimationController
              ..stop()
              ..reset();
          }
          //do not update dy if vertical swipe is not allowed
          final updated = _currentSession?.copyWith(
            currentPosition: widget.allowVerticalSwipe
                ? d.globalPosition
                : Offset(
                    d.globalPosition.dx, _currentSession!.currentPosition.dy),
          );
          widget.controller._updateSwipe(
            updated ??
                _SwipeSession(
                  localPosition: d.localPosition,
                  startPosition: d.globalPosition,
                  currentPosition: d.globalPosition,
                ),
          );
        },
        onPanEnd: (d) {
          if (!canSwipe) {
            return;
          }
          final swipeAssistDirection = _currentSession?.swipeAssistDirection(
            constraints: constraints,
            horizontalSwipeThreshold: widget.horizontalSwipeThreshold,
            verticalSwipeThreshold: widget.verticalSwipeThreshold,
          );

          if (swipeAssistDirection == null) {
            _cancelSwipe();
            return;
          }
          final allowMoveNext = widget.onWillMoveNext?.call(
                _currentIndex,
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
    widget.controller._updateSwipe(
      widget.controller.currentSession?.copyWith(
        currentPosition: positionAnimation.value,
      ),
    );
  }

  void _rewind({
    required Duration duration,
  }) {
    if (!canAnimationStart) {
      return;
    }
    final previousSession = widget.controller._previousSession;
    if (previousSession == null) {
      return;
    }
    widget.controller._prepareRewind();
    _rewindAnimationController.duration = duration;
    final rewindAnimation = _rewindAnimationController.cancelAnimation(
      startPosition: previousSession.startPosition,
      currentPosition: previousSession.currentPosition,
    );
    void _animate() {
      _animatePosition(rewindAnimation);
    }

    rewindAnimation.addListener(_animate);
    _rewindAnimationController.forward(from: 0).then(
      (_) {
        rewindAnimation.removeListener(_animate);
        widget.controller._initializeSessions();
      },
    ).catchError((dynamic c) {
      rewindAnimation.removeListener(_animate);
      widget.controller._initializeSessions();
    });
  }

  void _cancelSwipe() {
    final currentSession = widget.controller.currentSession;
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
        widget.controller.cancelAction();
      },
    ).catchError((dynamic c) {
      cancelAnimation.removeListener(_animate);
      widget.controller.cancelAction();
    });
  }

  void _swipeNext(SwipeDirection swipeDirection) {
    if (!canSwipe) {
      return;
    }
    final currentSession = widget.controller.currentSession;
    if (currentSession == null) {
      return;
    }
    final distToAssist = _distanceToAssist(
      swipeDirection: swipeDirection,
      context: context,
      difference: currentSession.difference,
    );
    _swipeAssistController.duration = _getSwipeAssistDuration(
      distToAssist: distToAssist,
      swipeDirection: swipeDirection,
      difference: currentSession.difference,
    );

    final animation = _swipeAssistController.swipeAnimation(
      startPosition: currentSession.currentPosition,
      endPosition: currentSession.currentPosition +
          _offsetToAssist(
            distToAssist: distToAssist,
            difference: currentSession.difference,
            context: context,
            swipeDirection: swipeDirection,
          ),
    );

    void animate() {
      _animatePosition(animation);
    }

    animation.addListener(animate);
    _swipeAssistController.forward(from: 0).then(
      (_) {
        animation.removeListener(animate);
        widget.onSwipeCompleted?.call(
          _currentIndex,
          swipeDirection,
        );
        widget.controller._completeAction();
      },
    ).catchError((dynamic c) {
      animation.removeListener(animate);
      widget.controller.cancelAction();
    });
  }

  void _next({
    required SwipeDirection swipeDirection,
    required bool shouldCallCompletionCallback,
    required bool ignoreOnWillMoveNext,
    Duration? duration,
  }) {
    if (!canAnimationStart) {
      return;
    }

    if (!ignoreOnWillMoveNext) {
      final allowMoveNext = widget.onWillMoveNext?.call(
            _currentIndex,
            swipeDirection,
          ) ??
          true;
      if (!allowMoveNext) {
        return;
      }
    }
    final startPosition = _SwipeSession.notMoving();
    widget.controller._updateSwipe(startPosition);
    final distToAssist = _distanceToAssist(
      swipeDirection: swipeDirection,
      context: context,
      difference: startPosition.difference,
    );
    _swipeAnimationController.duration = duration ??
        _getSwipeAnimationDuration(
          distToAssist: distToAssist,
          swipeDirection: swipeDirection,
          difference: startPosition.difference,
        );

    final animation = _swipeAnimationController.swipeAnimation(
      startPosition: startPosition.currentPosition,
      endPosition: _offsetToAssist(
        distToAssist: distToAssist,
        difference: swipeDirection.defaultOffset,
        context: context,
        swipeDirection: swipeDirection,
      ),
    );

    void animate() {
      _animatePosition(animation);
    }

    animation.addListener(animate);
    _swipeAnimationController.forward(from: 0).then(
      (_) {
        if (shouldCallCompletionCallback) {
          widget.onSwipeCompleted?.call(
            _currentIndex,
            swipeDirection,
          );
        }
        animation.removeListener(animate);
        widget.controller._completeAction();
      },
    ).catchError((dynamic c) {
      animation.removeListener(animate);
      widget.controller.cancelAction();
    });
  }

  @override
  void dispose() {
    _swipeCancelAnimationController.dispose();
    _swipeAnimationController.dispose();
    _swipeAssistController.dispose();
    _rewindAnimationController.dispose();
    widget.controller.removeListener(_listenController);
    super.dispose();
  }
}

class _SwipablePositioned extends StatelessWidget {
  const _SwipablePositioned({
    required this.index,
    required this.session,
    required this.areaConstraints,
    required this.child,
    required this.swipeDirectionRate,
    required this.viewFraction,
    this.swipeAnchor = SwipeAnchor.top,
    Key? key,
  })  : assert(0 <= viewFraction && viewFraction <= 1),
        super(key: key);

  static Widget overlay({
    required _SwipeSession session,
    required BoxConstraints areaConstraints,
    required Widget child,
    required _SwipeRatePerThreshold swipeDirectionRate,
    required double viewFraction,
  }) {
    return _SwipablePositioned(
      key: const ValueKey('overlay'),
      session: session,
      index: 0,
      viewFraction: viewFraction,
      areaConstraints: areaConstraints,
      swipeDirectionRate: swipeDirectionRate,
      child: IgnorePointer(
        child: child,
      ),
    );
  }

  final int index;
  final _SwipeSession session;
  final Widget child;
  final BoxConstraints areaConstraints;
  final _SwipeRatePerThreshold swipeDirectionRate;
  final double viewFraction;
  final SwipeAnchor swipeAnchor;

  Offset get _currentPositionDiff => session.difference;

  bool get _isFirst => index == 0;

  bool get _isSecond => index == 1;

  double get _rotationAngle => _isFirst
      ? swipeAnchor == SwipeAnchor.top
          ? calculateAngle(_currentPositionDiff.dx, areaConstraints.maxWidth)
          : -calculateAngle(_currentPositionDiff.dx, areaConstraints.maxWidth)
      : 0;

  static double calculateAngle(double differenceX, double areaWidth) {
    return -differenceX / areaWidth * math.pi / 18;
  }

  Offset get _rotationOrigin => _isFirst ? session.localPosition : Offset.zero;

  double get _animationRate => 1 - viewFraction;

  double _animationProgress() => Curves.easeOutCubic.transform(
        math.min(swipeDirectionRate.rate, 1),
      );

  BoxConstraints _constraints(BuildContext context) {
    if (_isFirst) {
      return areaConstraints;
    } else if (_isSecond) {
      return areaConstraints *
          (1 - _animationRate + _animationRate * _animationProgress());
    } else {
      return areaConstraints * (1 - _animationRate);
    }
  }

  Offset _preferredPosition(BuildContext context) {
    if (_isFirst) {
      return _currentPositionDiff;
    } else if (_isSecond) {
      final constraintsDiff =
          areaConstraints * (1 - _animationProgress()) * _animationRate / 2;
      return Offset(
        constraintsDiff.maxWidth,
        constraintsDiff.maxHeight,
      );
    } else {
      final maxDiff = areaConstraints * _animationRate / 2;
      return Offset(
        maxDiff.maxWidth,
        maxDiff.maxHeight,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final position = _preferredPosition(context);
    return Positioned(
      top: position.dy,
      left: position.dx,
      child: Transform.rotate(
        angle: _rotationAngle,
        alignment: Alignment.topLeft,
        origin: _rotationOrigin,
        child: ConstrainedBox(
          constraints: _constraints(context),
          child: IgnorePointer(
            ignoring: !_isFirst,
            child: child,
          ),
        ),
      ),
    );
  }
}
