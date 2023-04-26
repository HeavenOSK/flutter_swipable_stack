## [2.0.0]
- Update for Flutter V3
- Improve touch & feelings in Scrollable
  - adds `dragStartBehavior` and `hitTestBehavior`
  - adds dragstart animation
    - Thanks to [maeddin](https://github.com/maeddin)
- adds readme badges
  - Thanks to [maeddin](https://github.com/maeddin)

## [1.3.0]
- Add dragStartBehavior and hitTestBehavior 
  - Thanks to [maeddin](https://github.com/maeddin)

## [1.2.0]
- Add `detectableSwipeDirections` property.
  - The set of `SwipeDirection`s you want to detect as white-list.
## [1.1.0]
- Improve builder & overlayBuilder
  - You can get more information in builder from `SwipeProperties`(e.g. `stackIndex`)
  - BREAKING: bundled a lot of parameters of the builder into `SwipeProperties`.
  - Thanks to [maeddin](https://github.com/maeddin)
## [1.0.0]
- Add examples
- Update README
- Bug fixes
 
## [0.8.1]
- BugFix for [[Invalid value: Not in inclusive range #34
  ](https://github.com/HeavenOSK/flutter_swipable_stack/issues/34)]
  - Thanks to [@martesabt](https://github.com/martesabt) for the bug report.

## [0.8.0]
- Improve cancel & rewind animation
  - Added new options `cancelAnimationCurve` & `rewindAnimationCurve`
- Fix detectable area bug.
- Improve example.
## [0.7.1]
- Add `swipeAnchor` otpion
    - An option for setting anchor positon of swipe.
    - Thanks [kevsjh](https://github.com/kevsjh) :)

## [0.7.0+1]
- Fix typo on CHANGELOG

## [0.7.0]
- Add `allowVerticalSwipe` otpion
    - An option to controll the interaction for vertical swipe
    - Thanks [kevsjh](https://github.com/kevsjh) :)


## [0.6.2]
- Update state when `itemCount` is changed.

## [0.6.1]
- Fix [SwipableStackController.currentIndex] update

## [0.6.0]
- Add the option `stackClipBehaviour` to SwipableStack
    - You can change the `clipBehavior` of Stack.
    - Thanks [envomer](https://github.com/envomer) :)
- Optimize the update of SwipableStackController


## [0.5.0]
- Add `SwipableStack#swipeAssistDuration`
  - You can change the duration for swipe assist.
  - Thanks [rogiervandenberg](https://github.com/rogiervandenberg) :) 

## [0.4.0]

- Breaking changes:
    - Rename back to `Swipable` from `Swipeable` for consistency with package name.
        - Rename from `SwipeableStack` to `SwipableStack`.
        - Rename from `SwipeableStackController` to `SwipableStackController`.
- Be able to change duration of swipe & rewind animation.
- Add `ignoreOnWillMoveNext` option for SwipableStackController#next.
- Add `context` & `index` for SwipableStack#overlayBuilder to improve customizability.

## [0.3.0]

- Breaking changes:
    - Rename from SwipableStack to SwipeableStack.
    - Rename from SwipableStackController to SwipeableStackController.
- Refactor duration initialization for _swipeAssistController.

## [0.2.1] Fix typo.

## [0.2.0] Remove the suffix `nullsafety`. Fix README.

## [0.1.2-nullsafety.2] Add caring about unbound height or width.

## [0.1.2] Add caring about unbound height or width.

## [0.1.1-nullsafety.0] Migrate 0.1.1 to nullsafety

## [0.1.1] Bug fix.

## [0.1.0] Migrate to not nullsafety from 0.1.0-nullsafety.1

## [0.1.0-nullsafety.1] Refactor.

## [0.1.0-nullsafety.0] Migrate to nullsafety.

## [0.0.2] Update README.md

## [0.0.1] First release.











