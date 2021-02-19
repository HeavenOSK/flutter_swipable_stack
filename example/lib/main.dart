import 'package:example/card_label.dart';
import 'package:flutter/material.dart';
import 'package:swipable_stack/swipable_stack.dart';

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
  final double _bottomAreaHeight = 100;
  SwipableStackController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SwipableStackController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SwipableStack(
              controller: _controller,
              onSwipeCompleted: (index, direction) {
                print('$index, $direction');
              },
              overlayBuilder: (direction, value) {
                final isRight = direction == SwipeDirection.right;
                final isLeft = direction == SwipeDirection.left;

                return Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: _bottomAreaHeight,
                    horizontal: 16,
                  ),
                  child: Stack(
                    children: [
                      Opacity(
                        opacity: isRight ? value : 0,
                        child: CardLabel.like(),
                      ),
                      Opacity(
                        opacity: isLeft ? value : 0,
                        child: CardLabel.nope(),
                      ),
                    ],
                  ),
                );
              },
              builder: (_, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: _bottomAreaHeight,
                    horizontal: 16,
                  ),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 2,
                            color: Colors.black.withOpacity(0.15),
                            offset: Offset(0, 1),
                          ),
                          BoxShadow(
                            blurRadius: 4,
                            color: Colors.black.withOpacity(0.5),
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text('index:$index'),
                      ),
                    ),
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: _bottomAreaHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _BottomButton(
                      child: const Icon(Icons.navigate_before),
                      onPressed: () {
                        _controller.moveNext(SwipeDirection.left);
                      },
                    ),
                    _BottomButton(
                      onPressed: () {
                        _controller.moveNext(SwipeDirection.right);
                      },
                      child: const Icon(Icons.navigate_next),
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
}

class _BottomButton extends StatelessWidget {
  const _BottomButton({
    Key key,
    @required this.onPressed,
    @required this.child,
  }) : super(key: key);

  final Null Function() onPressed;
  final Icon child;

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
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
