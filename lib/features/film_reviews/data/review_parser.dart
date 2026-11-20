import '../../find/data/movie.dart';
import '../../home/data/home_models.dart';
import '../domain/film_reaction.dart';
import '../domain/movie_review_summary.dart';
import '../domain/poll_option.dart';
import '../domain/take_skin.dart';
import '../domain/review_stance.dart';
import '../domain/take.dart';
import '../domain/take_tag.dart';
import '../domain/topic_vote.dart';
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
      myReactions: [
        for (final value
            in (json['my_reactions'] as List<dynamic>? ?? const []))
          for (final reaction in FilmReaction.values)
            if (reaction.apiValue == value) reaction,
      ],
      total: (json['total'] as num?)?.toInt() ?? 0,
      counts: [
        if (json['counts'] case final Map<String, dynamic> counts)
          for (final reaction in FilmReaction.values)
            if ((counts[reaction.apiValue] as num?)?.toInt() case final count?
                when count > 0)
              ReactionCount(reaction: reaction, count: count),
      ],
    );
  }

  static List<Take> takes(List<Map<String, dynamic>> items) =>
      [for (final item in items) take(item)];

  static Take take(Map<String, dynamic> json) {
    final votes = json['votes'] as Map<String, dynamic>? ?? const {};
    final myVoteValues =
        json['my_votes'] as List<dynamic>? ?? const <dynamic>[];
    return Take(
      id: (json['id'] as num).toInt(),
      authorId: (json['author_id'] as num).toInt(),
      authorName: json['author_name'] as String,
      isMine: json['is_mine'] as bool? ?? false,
      reaction: _reactionOrNull(json['reaction'] as String?),
      authorReactions: [
        for (final value
            in (json['author_reactions'] as List<dynamic>? ?? const []))
          for (final reaction in FilmReaction.values)
            if (reaction.apiValue == value) reaction,
      ],
      authorFrame: json['author_frame'] as String?,
      body: json['body'] as String,
      tag: TakeTag.fromApi(json['tag'] as String?),
      imageUrl: json['image_url'] as String?,
      votes: {
        for (final kind in VoteKind.values)
          kind: (votes[kind.apiValue] as num?)?.toInt() ?? 0,
      },
      myVotes: {
        for (final value in myVoteValues)
          if (_voteOrNull(value) case final kind?) kind,
      },
      topicVotes: {
        for (final kind in TopicVote.values)
          kind: (votes[kind.apiValue] as num?)?.toInt() ?? 0,
      },
      myTopicVotes: {
        for (final value in myVoteValues)
          if (_topicVoteOrNull(value) case final kind?) kind,
      },
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      isMostHelpful: json['is_most_helpful'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      authorAvatarUrl: json['author_avatar'] as String?,
      spoiler: json['spoiler'] as bool? ?? false,
      skin: TakeSkin.fromApi(json['skin'] as String?),
      edited: json['edited'] as bool? ?? false,
      isSaved: json['is_saved'] as bool? ?? false,
      scene: json['scene'] as String? ?? '',
      title: json['title'] as String? ?? '',
      timecode: json['timecode'] as String? ?? '',
      pollOptions: [
        for (final option
            in (json['poll_options'] as List<dynamic>? ?? const <dynamic>[]))
          _pollOption(option as Map<String, dynamic>),
      ],
      myPollOptionId: (json['my_poll_option_id'] as num?)?.toInt(),
    );
  }

  static PollOption _pollOption(Map<String, dynamic> json) => PollOption(
        id: (json['id'] as num).toInt(),
        label: json['label'] as String? ?? '',
        votes: (json['votes'] as num?)?.toInt() ?? 0,
      );

  static List<FeedItem> exploreItems(List<Map<String, dynamic>> items) => [
        for (final item in items)
          FeedItem(
            film:
                _exploreFilm(item['film'] as Map<String, dynamic>? ?? const {}),
            take: take(item),
          ),
      ];

  static Film _exploreFilm(Map<String, dynamic> json) => Film(
        imdbId: json['film_id'] as String? ?? '',
        title: json['title'] as String?,
        posterUrl: json['poster_url'] as String?,
      );

  static List<TakeComment> comments(List<Map<String, dynamic>> items) =>
      [for (final item in items) comment(item)];

  static TakeComment comment(Map<String, dynamic> json) {
    return TakeComment(
      id: (json['id'] as num).toInt(),
      authorId: (json['author_id'] as num).toInt(),
      authorName: json['author_name'] as String,
      body: json['body'] as String,
      isWriter: json['is_writer'] as bool? ?? false,
      parentId: (json['parent_id'] as num?)?.toInt(),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      isMine: json['is_mine'] as bool? ?? false,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      dislikes: (json['dislikes'] as num?)?.toInt() ?? 0,
      myVote: _topicVoteOrNull(json['my_vote']),
      stance: ReviewStance.fromApi(json['stance']),
      imageUrl: json['image_url'] as String?,
      authorAvatarUrl: json['author_avatar'] as String?,
      authorFrame: json['author_frame'] as String?,
    );
  }

  static List<FriendFilmActivity> friendActivity(
    List<Map<String, dynamic>> items,
  ) =>
      [for (final item in items) friendActivityItem(item)];

  static FriendFilmActivity friendActivityItem(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    final take = json['take'] as Map<String, dynamic>?;
    return FriendFilmActivity(
      userId: (user['id'] as num).toInt(),
      username: user['username'] as String,
      avatarUrl: user['avatar'] as String?,
      frame: user['equipped_frame'] as String?,
      reaction: _reaction(json['reaction'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      takeId: (take?['id'] as num?)?.toInt(),
      takeBody: take?['body'] as String?,
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

  /// Review reaction for [value], or null for topic votes like `like`.
  static VoteKind? _voteOrNull(Object? value) {
    for (final kind in VoteKind.values) {
      if (kind.apiValue == value) return kind;
    }
    return null;
  }

  static TopicVote? _topicVoteOrNull(Object? value) {
    for (final kind in TopicVote.values) {
      if (kind.apiValue == value) return kind;
    }
    return null;
  }
}
