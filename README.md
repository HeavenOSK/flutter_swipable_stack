# swipable_stack
[![pub.dev](https://img.shields.io/pub/v/swipable_stack.svg?style=flat?logo=dart)](https://pub.dev/packages/swipable_stack)
[![github](https://img.shields.io/static/v1?label=platform&message=flutter&color=1ebbfd)](https://github.com/HeavenOSK/flutter_swipable_stack)
[![likes](https://img.shields.io/pub/likes/swipable_stack)](https://pub.dev/packages/swipable_stack/score)
[![popularity](https://img.shields.io/pub/popularity/swipable_stack.svg)](https://pub.dev/packages/swipable_stack/score)
[![pub points](https://img.shields.io/pub/points/swipable_stack)](https://pub.dev/packages/swipable_stack/score)
[![license](https://img.shields.io/github/license/HeavenOSK/flutter_swipable_stack.svg)](https://github.com/HeavenOSK/flutter_swipable_stack/blob/main/LICENSE)

A widget for stacking cards, which users can swipe horizontally and vertically with beautiful animations like Tinder UI.

![demo](https://github.com/HeavenOSK/gif_repository/blob/main/swipable_stack/demo.gif?raw=true)
 
(Sorry, the package name `swipable_stack` is typo of swipeable stack)
 
# Usage
## `builder`
A `SwipableStack` uses a builder to display widgets.
```dart
SwipableStack(
  builder: (context, properties) {
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
  overlayBuilder: (context, properties) {
    final opacity = min(properties.swipeProgress, 1.0);
    final isRight = properties.direction == SwipeDirection.right;
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
  builder: (context, properties) {
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

## `swipeAssistDuration`

You can set the speed the user is able to swipe through Widgets with the `swipeAssistDuration`.

```dart
SwipableStack(
  swipeAssistDuration: Duration(milliseconds: 100),
)
```

The default is 650ms.

## `stackClipBehaviour`

You can set the clipBehaviour of the stack with the `stackClipBehaviour`.  
Change it to `Clip.none` to exceed the boundaries of parent widget size.

```dart
SwipableStack(
  stackClipBehaviour: Clip.none,
)
```

The default is Clip.hardEdge.


## `allowVerticalSwipe`

Disable vertical swipe with `allowVerticalSwipe`.  
Changing to `false` disable vertical swipe capabilities

```dart
SwipableStack(
  allowVerticalSwipe: false,
)
```

The default is true.

## `swipeTopAnchor`

Set the swipe anchor with `swipeAnchor` with the following enum
SwipeAnchor.top : card rotation on bottom and anchored on top
SwipeAnchor.bottom : card rotation on top and anchored on bottom

```dart
SwipableStack(
  swipeAnchor: SwipeAnchor.top,
)
```

The default is SwipeAnchor.top.



