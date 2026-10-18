import 'package:equatable/equatable.dart';

/// Which list the user intends to add a chosen film to.
enum AddTarget {
  top5,
  watched,
  watchlist,
  generatePick,
}

/// Identifies a single destination within a target.
///
/// - `top5`: [index] is the slot 1..5 (0 for "any free slot").
/// - `generatePick`: [index] is the pick slot 0..2.
/// - `watched` / `watchlist`: [index] is unused.
typedef TargetSlot = ({AddTarget target, int index});

/// Human-readable label for a destination (for titles/chips).
String targetLabel(AddTarget target) => switch (target) {
      AddTarget.top5 => 'top5',
      AddTarget.watched => 'watched',
      AddTarget.watchlist => 'watchlist',
      AddTarget.generatePick => 'generate',
    };

/// The three persisted lists. Mirrors the backend list_type values.
enum FilmListId { top5, watched, watchlist }

/// A film as returned by the TMDB-backed search/detail proxy.
///
/// `id` is a string that is usually a numeric TMDB id going forward, but may
/// be a legacy IMDb id (`tt...`). The backend accepts both and resolves old ids.
class Movie extends Equatable {
  const Movie({
    required this.id,
    required this.title,
    this.year,
    this.posterUrl,
    this.backdropUrl,
    this.director,
    this.genres = const [],
    this.overview,
    this.runtime,
    this.voteAverage,
    this.watchProviders,
    this.inLists = const [],
  });

  final String id;
  final String title;
  final int? year;
  final String? posterUrl;
  final String? backdropUrl;
  final String? director;
  final List<String> genres;
  final String? overview;
  final int? runtime;
  final double? voteAverage;
  final WatchProviders? watchProviders;
  final List<String> inLists;

  bool get isTop5 => inLists.contains('top_5');
  bool get isWatched => inLists.contains('watched');
  bool get isWatchlist => inLists.contains('watchlist');

  String get displayTitle => title.isEmpty ? id : title;

  @override
  List<Object?> get props => [
        id,
        title,
        year,
        posterUrl,
        backdropUrl,
        director,
        genres,
        overview,
        runtime,
        voteAverage,
        watchProviders,
        inLists,
      ];
}

class WatchProviders extends Equatable {
  const WatchProviders({
    this.link,
    this.flatrate = const [],
    this.rent = const [],
    this.buy = const [],
  });

  final String? link;
  final List<StreamingProvider> flatrate;
  final List<StreamingProvider> rent;
  final List<StreamingProvider> buy;

  @override
  List<Object?> get props => [link, flatrate, rent, buy];
}

class StreamingProvider extends Equatable {
  const StreamingProvider({required this.name, this.logoUrl});

  final String name;
  final String? logoUrl;

  @override
  List<Object?> get props => [name, logoUrl];
}

/// A page of search results.
class MovieSearchPage extends Equatable {
  const MovieSearchPage({
    required this.page,
    required this.totalPages,
    required this.totalResults,
    required this.results,
  });

  final int page;
  final int totalPages;
  final int totalResults;
  final List<Movie> results;

  bool get hasMore => page < totalPages;

  @override
  List<Object?> get props => [page, totalPages, totalResults, results];
}

/// Typed failure mapped from the backend `{detail, code}` error body.
sealed class FindFailure implements Exception {
  const FindFailure(this.code, this.message);
  final String code;
  final String message;

  @override
  String toString() => 'FindFailure($code): $message';
}

final class NetworkFailure extends FindFailure {
  const NetworkFailure(String message) : super('network', message);
}

final class ServerFailure extends FindFailure {
  const ServerFailure(super.code, super.message);
}

final class AuthFailure extends FindFailure {
  const AuthFailure(String message) : super('unauthorized', message);
}

final class OfflineFailure extends FindFailure {
  const OfflineFailure() : super('offline', 'You are offline.');
}
