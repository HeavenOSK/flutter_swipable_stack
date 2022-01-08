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

class BasicExample extends StatefulWidget {
  const BasicExample._({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => BasicExample._(),
    );
  }

  @override
  _BasicExampleState createState() => _BasicExampleState();
}

class _BasicExampleState extends State<BasicExample> {
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
                  onSwipeCompleted: (index, direction) {
                    print('$index, $direction');
                  },
                  horizontalSwipeThreshold: 0.8,
                  verticalSwipeThreshold: 0.8,
                  builder: (context, index, stackIndex, constraints, direction, swipeProgress) {
                    final itemIndex = index % _images.length;
                    // for efficiency reasons
                    if(stackIndex > 1) return SizedBox();

                    return Stack(
                      children: [
                        ExampleCard(
                          name: 'Sample No.${itemIndex + 1}',
                          assetPath: _images[itemIndex],
                        ),
                        // more custom overlay possible than with overlayBuilder
                        if(stackIndex == 0) CardOverlay(
                          swipeProgress: swipeProgress,
                          direction: direction,
                        )
                      ],
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
