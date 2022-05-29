part of 'swipable_stack.dart';

/// An object to manipulate the [SwipableStack].
class SwipableStackController extends ChangeNotifier {
  SwipableStackController({
    int initialIndex = 0,
    this.maxRewindHistory = 1,
  })  : _currentIndex = initialIndex,
        assert(initialIndex >= 0);

  /// The key for [SwipableStack] to control.
  final _swipableStackStateKey = GlobalKey<_SwipableStackState>();

  int _currentIndex;

  /// How many items undo items we store in memory.
  /// Null means no limit on the number of history items.
  final int? maxRewindHistory;

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

  void _completeRewind() {
    _currentSessionState = null;
    _previousSessions.removeLast();
    notifyListeners();
  }

  void _completeAction() {
    if (currentSession != null) {
      _previousSessions.add(currentSession!);
    }
    if (maxRewindHistory != null &&
        _previousSessions.length > maxRewindHistory!) {

      _previousSessions.removeFirst();
    }
    _currentIndex += 1;
    _currentSessionState = null;
    notifyListeners();
  }

  void cancelAction() {
    _currentSessionState = null;
    notifyListeners();
  }

  void _prepareRewind() {
    _currentSessionState = _previousSessions.last;
    _currentIndex -= 1;
    notifyListeners();
  }

  final Queue<_SwipableStackPosition> _previousSessions =
      Queue<_SwipableStackPosition>();

  /// Whether to rewind.
  bool get canRewind => _previousSessions.isNotEmpty && _currentIndex > 0;

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
