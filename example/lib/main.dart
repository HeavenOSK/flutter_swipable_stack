import 'dart:math';

import 'package:example/card_label.dart';
import 'package:flutter/material.dart';
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
    return Colors.transparent;
  }
}

const _images = [
  'images/image_5.jpg',
  'images/image_3.jpg',
  'images/image_4.jpg',
];

void main() {
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
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SwipableStackController _controller;

  void _listenController() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _controller = SwipableStackController()..addListener(_listenController);
  }

  static const double _bottomPadding = 100;
  static const double _topPadding = 60;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('currentIndex:${_controller.currentIndex}'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SwipableStack(
              controller: _controller,
              onSwipeCompleted: (index, direction) {
                print('$index, $direction');
              },
              overlayBuilder: (constraints, direction, valuePerThreshold) {
                final opacity = min(valuePerThreshold, 1.0);

                final isRight = direction == SwipeDirection.right;
                final isLeft = direction == SwipeDirection.left;
                final isUp = direction == SwipeDirection.up;
                final isDown = direction == SwipeDirection.down;
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                  ).copyWith(
                    top: _topPadding + 16,
                  ),
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
                  padding: EdgeInsets.only(
                    top: _topPadding,
                    bottom: _bottomPadding,
                  ),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        imagePath,
                      ),
                    ),
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: _bottomPadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _BottomButton(
                      color: _controller.canRewind
                          ? Colors.amberAccent
                          : Colors.grey,
                      child: const Icon(Icons.refresh),
                      onPressed: _controller.canRewind
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
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.removeListener(_listenController);
    _controller.dispose();
  }
}

class _BottomButton extends StatelessWidget {
  const _BottomButton({
    Key key,
    @required this.onPressed,
    @required this.child,
    @required this.color,
  }) : super(key: key);

  final VoidCallback onPressed;
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
