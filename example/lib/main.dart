import 'package:example/examples/basic_example.dart';
import 'package:example/examples/detectable_directions_example.dart';
import 'package:example/examples/ignore_vertical_swipe_example.dart';
import 'package:example/examples/popup_on_swipe_example.dart';
import 'package:example/examples/swipe_anchor_example.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
              title: const Text('swipable_stack demo'),
            ),
            body: ListView(
              children: [
                ListTile(
                  title: const Text('BasicExample'),
                  onTap: () {
                    Navigator.push(
                      context,
                      BasicExample.route(),
                    );
                  },
                ),
                ListTile(
                  title: const Text('IgnoreVerticalSwipeExample'),
                  onTap: () {
                    Navigator.push(
                      context,
                      IgnoreVerticalSwipeExample.route(),
                    );
                  },
                ),
                ListTile(
                  title: const Text('PopupOnSwipeExample'),
                  onTap: () {
                    Navigator.push(
                      context,
                      PopupOnSwipeExample.route(),
                    );
                  },
                ),
                ListTile(
                  title: const Text('SwipeAnchorExample'),
                  onTap: () {
                    Navigator.push(
                      context,
                      SwipeAnchorExample.route(),
                    );
                  },
                ),
                ListTile(
                  title: const Text('DetectableDirectionsExample'),
                  onTap: () {
                    Navigator.push(
                      context,
                      DetectableDirectionsExample.route(),
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
