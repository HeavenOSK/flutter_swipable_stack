import 'package:example/examples/basic_example.dart';
import 'package:example/examples/detectable_directions_example.dart';
import 'package:example/examples/ignore_vertical_swipe_example.dart';
import 'package:example/examples/popup_on_swipe_example.dart';
import 'package:example/examples/swipe_anchor_example.dart';
import 'package:flutter/material.dart';

class GeneralHeader {
  const GeneralHeader._();

  static Positioned build(
    BuildContext context, {
    required String title,
  }) {
    final mediaQuery = MediaQuery.of(context);
    Future<void> navigate(Route<void> route) async {
      Navigator.of(context).pop();
      await Future<void>.delayed(const Duration(milliseconds: 150));
      await Navigator.of(context).pushReplacement<void, void>(route);
    }

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: kToolbarHeight + mediaQuery.padding.top,
        width: double.infinity,
        alignment: Alignment.centerRight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black54,
              Colors.transparent,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(top: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                ),
                child: Text(
                  '$title ',
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  primary: Colors.black54,
                  backgroundColor: Colors.white,
                ),
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (ctx) {
                      return Scaffold(
                        body: ListView(
                          children: [
                            ListTile(
                              title: const Text('BasicExample'),
                              onTap: () {
                                navigate(
                                  BasicExample.route(),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('IgnoreVerticalSwipeExample'),
                              onTap: () {
                                navigate(
                                  IgnoreVerticalSwipeExample.route(),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('PopupOnSwipeExample'),
                              onTap: () {
                                navigate(
                                  PopupOnSwipeExample.route(),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('SwipeAnchorExample'),
                              onTap: () {
                                navigate(
                                  SwipeAnchorExample.route(),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('DetectableDirectionsExample'),
                              onTap: () {
                                navigate(
                                  DetectableDirectionsExample.route(),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: const Text('more'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
