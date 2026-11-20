import 'package:equatable/equatable.dart';

/// Which list the user intends to add a chosen film to.
enum AddTarget {
  top5,
  watched,
  watchlist,
}

/// Identifies a single destination within a target.
///
/// - `top5`: [index] is the slot 1..5 (0 for "any free slot").
/// - `watched` / `watchlist`: [index] is unused.
typedef TargetSlot = ({AddTarget target, int index});

/// Human-readable label for a destination (for titles/chips).
String targetLabel(AddTarget target) => switch (target) {
      AddTarget.top5 => 'top5',
      AddTarget.watched => 'watched',
      AddTarget.watchlist => 'watchlist',
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
    this.trailerUrl,
    this.trailerYoutubeId,
    this.cast = const [],
    this.crew = const [],
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

  /// Direct trailer link (usually YouTube); null when the source has none.
  final String? trailerUrl;

  /// YouTube video id of the trailer, for the in-app player.
  final String? trailerYoutubeId;

  /// Main cast, billing order.
  final List<CastMember> cast;

  /// Key crew (director, writers, producers, composer…).
  final List<CrewMember> crew;

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
        trailerUrl,
        trailerYoutubeId,
        cast,
        crew,
      ];
}

/// An actor and the character they play.
class CastMember extends Equatable {
  const CastMember({required this.name, this.role = '', this.personId});

  final String name;
  final String role;

  /// Backend person id for the person page; null when unknown.
  final String? personId;

  @override
  List<Object?> get props => [name, role, personId];
}

/// A crew member and their job(s), e.g. "Director, Screenplay".
class CrewMember extends Equatable {
  const CrewMember({required this.name, this.job = '', this.personId});

  final String name;
  final String job;

  /// Backend person id for the person page; null when unknown.
  final String? personId;

  @override
  List<Object?> get props => [name, job, personId];
}

/// How a streaming option is offered.
enum ProviderOffer {
  subscription('sub'),
  free('free'),
  tvProvider('tve'),
  rent('rent'),
  buy('buy');

  const ProviderOffer(this.apiValue);

  final String apiValue;

  static ProviderOffer? fromApi(Object? value) {
    for (final offer in values) {
      if (offer.apiValue == value) return offer;
    }
    return null;
  }
}

class WatchProviders extends Equatable {
  const WatchProviders({
    this.link,
    this.available = const [],
  });

  final String? link;
  final List<StreamingProvider> available;

  @override
  List<Object?> get props => [link, available];
}

class StreamingProvider extends Equatable {
  const StreamingProvider({
    required this.name,
    this.logoUrl,
    this.url,
    this.offer,
    this.price,
  });

  final String name;
  final String? logoUrl;
  final String? url;

  /// Subscription, free, rent…; null when the source does not say.
  final ProviderOffer? offer;

  /// Rent/buy price in the streaming country's currency, when known.
  final double? price;

  @override
  List<Object?> get props => [name, logoUrl, url, offer, price];
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
