part of 'swipable_stack.dart';

/// An object to manipulate the [SwipableStack].
class SwipableStackController extends ChangeNotifier {
  SwipableStackController({
    int initialIndex = 0,
  })  : _currentIndex = initialIndex,
        assert(initialIndex >= 0);

  /// The key for [SwipableStack] to control.
  final _swipableStackStateKey = GlobalKey<_SwipableStackState>();

  int _currentIndex;

  /// Current index of [SwipableStack].
  int get currentIndex => _currentIndex;

  set currentIndex(int newValue) {
    if (_currentIndex == newValue) {
      return;
    }
    _currentIndex = newValue;
    notifyListeners();
  }

  _SwipableStackPosition? _currentSessionState;

  /// The current session that user swipes.
  ///
  /// If you doesn't touch or finished the session, It would be null.
  _SwipableStackPosition? get currentSession => _currentSessionState;

  void _updateSwipe(_SwipableStackPosition? session) {
    if (_currentSessionState == session) {
      return;
    }
    _currentSessionState = session;
    notifyListeners();
  }

  void _initializeSessions() {
    _currentSessionState = null;
    _previousSession = null;
    notifyListeners();
  }

  void _completeAction() {
    _previousSession = currentSession?.copyWith();
    _currentIndex += 1;
    _currentSessionState = null;
    notifyListeners();
  }

  void cancelAction() {
    _currentSessionState = null;
    notifyListeners();
  }

  void _prepareRewind() {
    _currentSessionState = _previousSession?.copyWith();
    _currentIndex -= 1;
    notifyListeners();
  }

  _SwipableStackPosition? _previousSession;

  /// Whether to rewind.
  bool get canRewind => _previousSession != null && _currentIndex > 0;

  /// Advance to the next card with specified [swipeDirection].
  ///
  /// You can reject [SwipableStack.onSwipeCompleted] invocation by
  /// setting [shouldCallCompletionCallback] to false.
  ///
  /// You can ignore checking with [SwipableStack#onWillMoveNext] by
  /// setting [ignoreOnWillMoveNext] to true.
  ///
  /// You can change animation speed by setting [duration].
  void next({
    required SwipeDirection swipeDirection,
    bool shouldCallCompletionCallback = true,
    bool ignoreOnWillMoveNext = false,
    Duration? duration,
  }) {
    _swipableStackStateKey.currentState?._next(
      swipeDirection: swipeDirection,
      shouldCallCompletionCallback: shouldCallCompletionCallback,
      ignoreOnWillMoveNext: ignoreOnWillMoveNext,
      duration: duration,
    );
  }

  /// Rewind the most recent action.
  ///
  /// You can change animation speed by setting [duration].
  void rewind({
    Duration duration = SwipableStack._defaultRewindDuration,
  }) {
    _swipableStackStateKey.currentState?._rewind(
      duration: duration,
    );
  }
}
