import 'dart:math';

import 'package:example/card_label.dart';
import 'package:flutter/material.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:swipable_stack/swipable_stack.dart';

class SwipeDirectionColor {
  static const right = Color.fromRGBO(70, 195, 120, 1);
  static const left = Color.fromRGBO(220, 90, 108, 1);
  static const up = Color.fromRGBO(83, 170, 232, 1);
  static const down = Color.fromRGBO(154, 85, 215, 1);
}

extension SwipeDirecionX on SwipeDirection {
  Color get color {
    switch (this) {
      case SwipeDirection.right:
        return Color.fromRGBO(70, 195, 120, 1);
      case SwipeDirection.left:
        return Color.fromRGBO(220, 90, 108, 1);
      case SwipeDirection.up:
        return Color.fromRGBO(83, 170, 232, 1);
      case SwipeDirection.down:
        return Color.fromRGBO(154, 85, 215, 1);
    }
  }
}

const _images = [
  'images/image_5.jpg',
  'images/image_3.jpg',
  'images/image_4.jpg',
];

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _controller = SwipableStackController();
  late final RemoveListener _removeListener;
  int _currentIndex = 0;
  bool _canRewind = false;

  @override
  void initState() {
    super.initState();
    _removeListener = _controller.addListener(
      (state) {
        setState(() {
          _currentIndex = state.currentIndex;
          _canRewind = state.canRewind;
        });
      },
    );
  }

  static const double _bottomAreaHeight = 100;

  static const EdgeInsets _padding = EdgeInsets.all(16);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('currentIndex:${_currentIndex}'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SwipableStack(
                controller: _controller,
                stackClipBehaviour: Clip.none,
                onSwipeCompleted: (index, direction) {
                  print('$index, $direction');
                },
                overlayBuilder: (
                  context,
                  constraints,
                  index,
                  direction,
                  swipeProgress,
                ) {
                  final opacity = min(swipeProgress, 1.0);

                  final isRight = direction == SwipeDirection.right;
                  final isLeft = direction == SwipeDirection.left;
                  final isUp = direction == SwipeDirection.up;
                  final isDown = direction == SwipeDirection.down;
                  return Padding(
                    padding: _padding * 3,
                    child: Stack(
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
                    ),
                  );
                },
                builder: (context, index, constraints) {
                  final imagePath = _images[index % _images.length];
                  return Padding(
                    padding: _padding,
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Image.asset(
                            imagePath,
                            height: constraints.maxHeight,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: _bottomAreaHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _BottomButton(
                    color: _canRewind ? Colors.amberAccent : Colors.grey,
                    child: const Icon(Icons.refresh),
                    onPressed: _canRewind
                        ? () {
                            _controller.rewind();
                          }
                        : null,
                  ),
                  _BottomButton(
                    color: SwipeDirectionColor.left,
                    child: const Icon(Icons.arrow_back),
                    onPressed: () {
                      _controller.next(
                        swipeDirection: SwipeDirection.left,
                      );
                    },
                  ),
                  _BottomButton(
                    color: SwipeDirectionColor.up,
                    onPressed: () {
                      _controller.next(
                        swipeDirection: SwipeDirection.up,
                      );
                    },
                    child: const Icon(Icons.arrow_upward),
                  ),
                  _BottomButton(
                    color: SwipeDirectionColor.right,
                    onPressed: () {
                      _controller.next(
                        swipeDirection: SwipeDirection.right,
                      );
                    },
                    child: const Icon(Icons.arrow_forward),
                  ),
                  _BottomButton(
                    color: SwipeDirectionColor.down,
                    onPressed: () {
                      _controller.next(
                        swipeDirection: SwipeDirection.down,
                      );
                    },
                    child: const Icon(Icons.arrow_downward),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _removeListener();
    _controller.dispose();
  }
}

class _BottomButton extends StatelessWidget {
  const _BottomButton({
    required this.onPressed,
    required this.child,
    required this.color,
    Key? key,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final Icon child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      width: 64,
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.resolveWith(
            (states) => RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          backgroundColor: MaterialStateProperty.resolveWith(
            (states) => color,
          ),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
