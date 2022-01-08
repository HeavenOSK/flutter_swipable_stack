import 'package:example/widgets/bottom_buttons_row.dart';
import 'package:example/widgets/card_overlay.dart';
import 'package:example/widgets/example_card.dart';
import 'package:flutter/material.dart';
import 'package:swipable_stack/swipable_stack.dart';

const _images = [
  'images/image_5.jpg',
  'images/image_3.jpg',
  'images/image_4.jpg',
];

class SwipeAnchorExample extends StatefulWidget {
  const SwipeAnchorExample._({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => SwipeAnchorExample._(),
    );
  }

  @override
  _SwipeAnchorExampleState createState() => _SwipeAnchorExampleState();
}

class _SwipeAnchorExampleState extends State<SwipeAnchorExample> {
  late final SwipableStackController _controller;

  void _listenController() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _controller = SwipableStackController()..addListener(_listenController);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.removeListener(_listenController);
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SwipableStack(
                  controller: _controller,
                  stackClipBehaviour: Clip.none,
                  // If you want to change the position of anchor for cards,
                  // set [swipeAnchor].
                  swipeAnchor: SwipeAnchor.bottom,
                  onWillMoveNext: (index, swipeDirection) {
                    // Return true for the desired swipe direction.
                    switch (swipeDirection) {
                      case SwipeDirection.left:
                      case SwipeDirection.right:
                        return true;
                      case SwipeDirection.none:
                      case SwipeDirection.up:
                      case SwipeDirection.down:
                        return false;
                    }
                  },
                  onSwipeCompleted: (index, direction) {
                    print('$index, $direction');
                  },
                  horizontalSwipeThreshold: 0.8,
                  // Set max value to ignore vertical threshold.
                  verticalSwipeThreshold: 1,
                  overlayBuilder: (
                    context,
                    constraints,
                    index,
                    direction,
                    swipeProgress,
                  ) =>
                      CardOverlay(
                    swipeProgress: swipeProgress,
                    direction: direction,
                  ),
                  builder: (context, index, stackIndex, constraints, direction, progress) {
                    final itemIndex = index % _images.length;
                    return ExampleCard(
                      name: 'Sample No.${itemIndex + 1}',
                      assetPath: _images[itemIndex],
                    );
                  },
                ),
              ),
            ),
            BottomButtonsRow(
              onSwipe: (direction) {
                _controller.next(swipeDirection: direction);
              },
              onRewindTap: _controller.rewind,
              canRewind: _controller.canRewind,
            ),
          ],
        ),
      ),
    );
  }
}
