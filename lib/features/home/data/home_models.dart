import 'package:equatable/equatable.dart';

import '../../film_reviews/domain/take.dart';

enum HomeList { top5, watched, watchlist, popular }

abstract final class HomeLimits {
  static const top5Slots = 5;
  static const feedFilmLimit = 12;
  static const feedTakeLimit = 20;
}

class Film extends Equatable {
  const Film({required this.imdbId, this.title, this.posterUrl});

  final String imdbId;
  final String? title;
  final String? posterUrl;

  String get displayTitle => title ?? imdbId;

  @override
  List<Object?> get props => [imdbId, title, posterUrl];
}

class FeedItem extends Equatable {
  const FeedItem({required this.film, required this.take});

  final Film film;
  final Take take;

  @override
  List<Object?> get props => [film, take];
}

class HomeDataException implements Exception {
  const HomeDataException(this.message);

  final String message;

  @override
  String toString() => 'HomeDataException: $message';
}
