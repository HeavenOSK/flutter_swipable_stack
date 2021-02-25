# swipable_stack
A widget for stacking cards, which users can swipe horizontally and vertically with beautiful animations.

<img src='https://user-images.githubusercontent.com/19836917/109180799-9adbda80-77ce-11eb-88e0-dbd8ad50df7d.gif' width=400px>
 
# Usage
## `builder`
A `SwipableStack` uses a builder to display widgets.
```dart
SwipableStack(
  builder: (context, index, constraints) {
    return Image.asset(imagePath);
  },
),
```
## `onSwipeCompleted`
You can get completion event with `onSwipeCompleted`.
```dart
SwipableStack(
  onSwipeCompleted: (index, direction) {
    print('$index, $direction');
  },
)
```

## `overlayBuilder`
You can show overlay on the front card with `overlayBuilder`.
```dart
SwipableStack(
  overlayBuilder: (constraints, direction, valuePerThreshold) {
    final opacity = min(valuePerThreshold, 1.0);
    final isRight = direction == SwipeDirection.right;
    return Opacity(
      opacity: isRight ? opacity : 0,
      child: CardLabel.right(),
    );
  },
)
```

## `controller`
`SwipableStackController` allows you to control swipe action & also rewind recent action.
 
```dart
final controller = SwipableStackController();

SwipableStack(
  controller:controller,
  builder: (context, index, constraints) {
    return Image.asset(imagePath);
  },
);
controller.next(
  swipeDirection: SwipeDirection.right,
);
controller.rewind();
```

`SwipableStackController` provides to access `currentIndex` of `SwipableStack`.
```dart
final controller = SwipableStackController();
controller.addListener(() {
  print('${_controller.currentIndex}');
});
```

## `onWillMoveNext`
You can also restrict user actions according to index or action with `onWillMoveNext`.
```dart
SwipableStack(
  onWillMoveNext: (index, direction) {
    final allowedActions = [
      SwipeDirection.right,
      SwipeDirection.left,
    ];
    return allowedActions.contains(direction);
  },
);
```

