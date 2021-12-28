import 'package:example/examples/allow_swipe_direction.dart';
import 'package:example/examples/basic_example.dart';
import 'package:example/examples/popup_on_swipe_example.dart';
import 'package:example/examples/swipe_anchor_example.dart';
import 'package:flutter/material.dart';

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
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('swipable_stack demo'),
            ),
            body: ListView(
              children: [
                ListTile(
                  title: Text('Basic'),
                  onTap: () {
                    Navigator.push(
                      context,
                      BasicExample.route(),
                    );
                  },
                ),
                ListTile(
                  title: Text('IgnoreVerticalSwipeExample'),
                  onTap: () {
                    Navigator.push(
                      context,
                      IgnoreVerticalSwipeExample.route(),
                    );
                  },
                ),
                ListTile(
                  title: Text('PopupOnSwipeExample'),
                  onTap: () {
                    Navigator.push(
                      context,
                      PopupOnSwipeExample.route(),
                    );
                  },
                ),
                ListTile(
                  title: Text('SwipeAnchorExample'),
                  onTap: () {
                    Navigator.push(
                      context,
                      SwipeAnchorExample.route(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
