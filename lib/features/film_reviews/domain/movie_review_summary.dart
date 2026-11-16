import 'package:equatable/equatable.dart';

import 'film_reaction.dart';

class MovieReviewSummary extends Equatable {
  const MovieReviewSummary({
    required this.myReaction,
    required this.mostFelt,
    required this.everyonePercent,
    required this.trustedPercent,
    this.myReactions = const [],
    this.total = 0,
    this.counts = const [],
  });

  /// Up to three feelings in pick order, so the film page can show them all.
  static const maxFeelings = 3;

  /// The viewer's first feeling (older single-reaction screens use this).
  final FilmReaction? myReaction;

  /// All of the viewer's feelings for the film, in pick order.
  final List<FilmReaction> myReactions;

  /// How many people reacted (each may pick up to [maxFeelings] feelings).
  final int total;

  /// How many people picked each feeling, every feeling with at least one.
  /// [mostFelt] is only the top three.
  final List<ReactionCount> counts;

  /// Every feeling's count for the audience bar, falling back to [mostFelt]
  /// for payloads without the full counts.
  List<ReactionCount> get allCounts => counts.isNotEmpty ? counts : mostFelt;

  /// The viewer's feelings, falling back to [myReaction] for older payloads.
  List<FilmReaction> get feelings => myReactions.isNotEmpty
      ? myReactions
      : [if (myReaction case final reaction?) reaction];
  final List<ReactionCount> mostFelt;
  final int? everyonePercent;
  final int? trustedPercent;

  MovieReviewSummary withReaction(FilmReaction? reaction) =>
      withFeelings([if (reaction != null) reaction]);

  /// A copy with the viewer's feelings replaced (used for optimistic updates).
  MovieReviewSummary withFeelings(List<FilmReaction> feelings) =>
      MovieReviewSummary(
        myReaction: feelings.isEmpty ? null : feelings.first,
        myReactions: feelings,
        mostFelt: mostFelt,
        everyonePercent: everyonePercent,
        trustedPercent: trustedPercent,
        total: total,
        counts: counts,
      );

  @override
  List<Object?> get props => [
        myReaction,
        myReactions,
        mostFelt,
        everyonePercent,
        trustedPercent,
        total,
        counts,
      ];
}

class ReactionCount extends Equatable {
  const ReactionCount({required this.reaction, required this.count});

  final FilmReaction reaction;
  final int count;

  @override
  List<Object?> get props => [reaction, count];
}
