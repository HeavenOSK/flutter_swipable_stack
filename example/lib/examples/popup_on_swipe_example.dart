import 'package:example/widgets/bottom_buttons_row.dart';
import 'package:example/widgets/card_overlay.dart';
import 'package:example/widgets/example_card.dart';
import 'package:example/widgets/fade_route.dart';
import 'package:example/widgets/general_drawer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:swipable_stack/swipable_stack.dart';

const _images = [
  'images/image_5.jpg',
  'images/image_3.jpg',
  'images/image_4.jpg',
];

class PopupOnSwipeExample extends StatefulWidget {
  const PopupOnSwipeExample._();

  static Route<void> route() {
    return FadeRoute(
      builder: (context) => const PopupOnSwipeExample._(),
    );
  }

  @override
  _PopupOnSwipeExampleState createState() => _PopupOnSwipeExampleState();
}

class _PopupOnSwipeExampleState extends State<PopupOnSwipeExample> {
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
    _controller
      ..removeListener(_listenController)
      ..dispose();
  }

  @override
  Widget build(BuildContext context) {
    const pointCount = 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('PopupOnSwipeExample'),
      ),
      drawer: const GeneralDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: SwipableStack(
                  controller: _controller,
                  stackClipBehaviour: Clip.none,
                  onWillMoveNext: (index, direction) {
                    // You can reject user swipe actions and also
                    // show popup as following.
                    if (pointCount <= 0) {
                      Future(() async {
                        await _PopUp.show(context: context);
                      });
                      return false;
                    }
                    return true;
                  },
                  onSwipeCompleted: (index, direction) {
                    if (kDebugMode) {
                      print('$index, $direction');
                    }
                  },
                  horizontalSwipeThreshold: 0.8,
                  verticalSwipeThreshold: 0.8,
                  overlayBuilder: (
                    context,
                    properties,
                  ) =>
                      CardOverlay(
                    swipeProgress: properties.swipeProgress,
                    direction: properties.direction,
                  ),
                  builder: (context, properties) {
                    final itemIndex = properties.index % _images.length;
                    return ExampleCard(
                      name: 'Sample No.${itemIndex + 1}',
                      assetPath: _images[itemIndex],
                    );
                  },
                ),
              ),
            ),
            BottomButtonsRow(
              onSwipe: (direction) async {
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

class _PopUp {
  const _PopUp._();

  static Future<void> show({
    required BuildContext context,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Example Popup'),
        content: const Text(
          'Example message\n'
          '- You need more points. \n'
          '- Your account is not available\n',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }
}
