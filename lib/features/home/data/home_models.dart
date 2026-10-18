import 'package:equatable/equatable.dart';

enum HomeList { top5, watched, watchlist, popular }

abstract final class HomeLimits {
  static const top5Slots = 5;
  static const recommendPicks = 3;
  static const pointsPerGenerate = 100;
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

class HomeDataException implements Exception {
  const HomeDataException(this.message);

  final String message;

  @override
  String toString() => 'HomeDataException: $message';
}
