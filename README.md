# swipable_stack
A widget for stacking cards, which users can swipe horizontally and vertically with beautiful animations.

<img src='https://user-images.githubusercontent.com/19836917/109180799-9adbda80-77ce-11eb-88e0-dbd8ad50df7d.gif' width=400px>
 
(Sorry, the package name `swipable_stack` is typo of swipeable stack)
 
# Usage
## `builder`
A `SwipeableStack` uses a builder to display widgets.
```dart
SwipeableStack(
  builder: (context, index, constraints) {
    return Image.asset(imagePath);
  },
),
```
## `onSwipeCompleted`
You can get completion event with `onSwipeCompleted`.
```dart
SwipeableStack(
  onSwipeCompleted: (index, direction) {
    print('$index, $direction');
  },
)
```

## `overlayBuilder`
You can show overlay on the front card with `overlayBuilder`.
```dart
SwipeableStack(
  overlayBuilder: (
    context,
    constraints,
    index,
    direction,
    swipeProgress,
  ) {
    final opacity = min(swipeProgress, 1.0);
    final isRight = direction == SwipeDirection.right;
    return Opacity(
      opacity: isRight ? opacity : 0,
      child: CardLabel.right(),
    );
  },
)
```

## `controller`
`SwipeableStackController` allows you to control swipe action & also rewind recent action.
 
```dart
final controller = SwipeableStackController();

SwipeableStack(
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

`SwipeableStackController` provides to access `currentIndex` of `SwipeableStack`.
```dart
final controller = SwipeableStackController();
controller.addListener(() {
  print('${_controller.currentIndex}');
});
```

## `onWillMoveNext`
You can also restrict user actions according to index or action with `onWillMoveNext`.
```dart
SwipeableStack(
  onWillMoveNext: (index, direction) {
    final allowedActions = [
      SwipeDirection.right,
      SwipeDirection.left,
    ];
    return allowedActions.contains(direction);
  },
);
```

