import '../data/movie.dart';

/// Typed arguments for opening the Find film screen.
class FindFilmRouteArgs {
  const FindFilmRouteArgs({
    this.target,
    this.slot = 0,
    this.pickIndex = 0,
  });

  /// Destination context. `null` means the screen was opened from the global
  /// search icon, so each result shows a menu to choose where to add it.
  final AddTarget? target;

  /// 1-based Top 5 slot when [target] is [AddTarget.top5].
  final int slot;

  /// 0-based pick slot when [target] is [AddTarget.generatePick].
  final int pickIndex;
}

/// Typed result returned when the screen pops after a successful add.
class FindFilmResult {
  const FindFilmResult({this.film, this.target});

  final Movie? film;
  final AddTarget? target;

  bool get added => film != null;
}
