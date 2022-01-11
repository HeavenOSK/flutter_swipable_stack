import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipable_stack/src/swipable_stack.dart';

final _cardColors = <Color>[
  ...Colors.primaries,
  ...Colors.accents,
];

Widget _buildCard({
  required Color color,
  required int index,
}) =>
    Container(
      key: UniqueKey(),
      height: double.infinity,
      width: double.infinity,
      color: color,
      alignment: Alignment.center,
      child: Text('$index'),
    );

Widget _buildApp({
  required int cardCount,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SwipableStack(
        itemCount: cardCount,
        builder: (context, properties) {
          final color = _cardColors[properties.index % _cardColors.length];
          return _buildCard(
            color: color,
            index: properties.index,
          );
        },
      ),
    ),
  );
}

void main() {
  group(
    '[SwipableStack]',
    () {
      testWidgets(
        'can build when itemCount is 0, 1, 2, 3...10',
        (tester) async {
          for (var i = 0; i < 10; i++) {
            await tester.pumpWidget(_buildApp(cardCount: i));
          }
        },
      );
    },
  );
}
