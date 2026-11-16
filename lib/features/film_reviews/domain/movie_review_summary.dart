import 'package:equatable/equatable.dart';

import 'film_reaction.dart';

class MovieReviewSummary extends Equatable {
  const MovieReviewSummary({
    required this.myReaction,
    required this.mostFelt,
    required this.everyonePercent,
    required this.trustedPercent,
  });

  final FilmReaction? myReaction;
  final List<ReactionCount> mostFelt;
  final int? everyonePercent;
  final int? trustedPercent;

  MovieReviewSummary withReaction(FilmReaction? reaction) => MovieReviewSummary(
        myReaction: reaction,
        mostFelt: mostFelt,
        everyonePercent: everyonePercent,
        trustedPercent: trustedPercent,
      );

  @override
  List<Object?> get props =>
      [myReaction, mostFelt, everyonePercent, trustedPercent];
}

class ReactionCount extends Equatable {
  const ReactionCount({required this.reaction, required this.count});

  final FilmReaction reaction;
  final int count;

  @override
  List<Object?> get props => [reaction, count];
}
