class SwipableStackState {
  const SwipableStackState({
    this.currentIndex = 0,
    this.canRewind = false,
  });

  final int currentIndex;
  final bool canRewind;

  @override
  bool operator ==(Object other) =>
      other is SwipableStackState &&
      currentIndex == other.currentIndex &&
      canRewind == other.canRewind;

  @override
  int get hashCode =>
      runtimeType.hashCode ^ currentIndex.hashCode ^ canRewind.hashCode;

  SwipableStackState copyWith({
    int? currentIndex,
    bool? canRewind,
  }) =>
      SwipableStackState(
        currentIndex: currentIndex ?? this.currentIndex,
        canRewind: canRewind ?? this.canRewind,
      );
}
