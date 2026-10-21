import '../../find/data/movie.dart';
import '../domain/film_reaction.dart';
import '../domain/movie_review_summary.dart';
import '../domain/take.dart';
import '../domain/vote_kind.dart';

class ReviewParser {
  const ReviewParser._();

  static MovieReviewSummary summary(Map<String, dynamic> json) {
    return MovieReviewSummary(
      myReaction: _reactionOrNull(json['my_reaction'] as String?),
      mostFelt: [
        for (final item in (json['most_felt'] as List<dynamic>? ?? const []))
          ReactionCount(
            reaction: _reaction(
              (item as Map<String, dynamic>)['reaction'] as String,
            ),
            count: (item['count'] as num).toInt(),
          ),
      ],
      everyonePercent: (json['everyone_percent'] as num?)?.toInt(),
      trustedPercent: (json['trusted_percent'] as num?)?.toInt(),
    );
  }

  static List<Take> takes(List<Map<String, dynamic>> items) =>
      [for (final item in items) take(item)];

  static Take take(Map<String, dynamic> json) {
    final votes = json['votes'] as Map<String, dynamic>? ?? const {};
    return Take(
      id: (json['id'] as num).toInt(),
      authorId: (json['author_id'] as num).toInt(),
      authorName: json['author_name'] as String,
      isMine: json['is_mine'] as bool? ?? false,
      reaction: _reaction(json['reaction'] as String),
      body: json['body'] as String,
      votes: {
        for (final kind in VoteKind.values)
          kind: (votes[kind.apiValue] as num?)?.toInt() ?? 0,
      },
      myVotes: {
        for (final value in (json['my_votes'] as List<dynamic>? ?? const []))
          _vote(value as String),
      },
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      isMostHelpful: json['is_most_helpful'] as bool? ?? false,
    );
  }

  static List<TakeComment> comments(List<Map<String, dynamic>> items) =>
      [for (final item in items) comment(item)];

  static TakeComment comment(Map<String, dynamic> json) {
    return TakeComment(
      id: (json['id'] as num).toInt(),
      authorId: (json['author_id'] as num).toInt(),
      authorName: json['author_name'] as String,
      body: json['body'] as String,
      isWriter: json['is_writer'] as bool? ?? false,
    );
  }

  static FilmReaction _reaction(String value) {
    for (final reaction in FilmReaction.values) {
      if (reaction.apiValue == value) return reaction;
    }
    throw ServerFailure('bad_response', 'Unexpected reaction from server.');
  }

  static FilmReaction? _reactionOrNull(String? value) =>
      value == null ? null : _reaction(value);

  static VoteKind _vote(String value) {
    for (final kind in VoteKind.values) {
      if (kind.apiValue == value) return kind;
    }
    throw ServerFailure('bad_response', 'Unexpected vote from server.');
  }
}
