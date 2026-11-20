import 'package:image_picker/image_picker.dart';

import '../../home/data/home_models.dart';
import '../domain/film_reaction.dart';
import '../domain/movie_review_summary.dart';
import '../domain/review_stance.dart';
import '../domain/take.dart';
import '../domain/take_skin.dart';
import '../domain/take_tag.dart';
import '../domain/topic_vote.dart';
import '../domain/vote_kind.dart';

abstract interface class ReviewRepository {
  Future<MovieReviewSummary> fetchSummary(String filmId);

  Future<MovieReviewSummary> setReaction(String filmId, FilmReaction? reaction);

  Future<List<Take>> fetchTakes(String filmId);

  Future<Take> postTake(
    String filmId, {
    required String body,
    TakeTag tag = TakeTag.review,
    TakeSkin skin = TakeSkin.normal,
    bool spoiler = false,
  });

  /// Posts a question, discussion, hot take, poll or scene. [filmId] is
  /// required for scenes. [options] (2 to 4) are required for polls, and
  /// [scene] is required for scenes.
  Future<Take> postTopic({
    String? filmId,
    required String body,
    required TakeTag tag,
    XFile? image,
    List<String> options = const [],
    String? scene,
    String? timecode,
    bool spoiler = false,
    TakeSkin skin = TakeSkin.normal,
    String title = '',
  });

  /// Newest takes, questions and discussions across all films.
  Future<List<FeedItem>> fetchExploreFeed();

  /// Newest reviews written by accepted friends, across all films.
  Future<List<FeedItem>> fetchFriendTakes();

  /// The viewer's own reviews, newest first.
  Future<List<FeedItem>> fetchMyTakes();

  /// Questions and discussions from the last week, ranked by replies and votes.
  Future<List<FeedItem>> fetchTrendingTopics();

  Future<Take> setVote(int takeId, VoteKind kind, {required bool active});

  /// Like or dislike on a question or discussion.
  Future<Take> setTopicVote(int takeId, TopicVote kind, {required bool active});

  /// Saves someone's take to come back to, or unsaves it.
  Future<Take> setSaved(int takeId, {required bool active});

  /// The takes the viewer saved, most recently saved first.
  Future<List<FeedItem>> fetchSavedTakes();

  /// Sets the viewer's choice on a poll, replacing any earlier choice.
  /// Returns the poll with fresh counts.
  Future<Take> setPollVote(int takeId, int optionId);

  Future<List<TakeComment>> fetchComments(int takeId);

  /// Like or dislike on a comment. Returns the comment with fresh counts.
  Future<TakeComment> setCommentVote(
    int commentId,
    TopicVote kind, {
    required bool active,
  });

  Future<TakeComment> postComment(
    int takeId, {
    required String body,
    int? parentId,
    ReviewStance? stance,

    /// An optional photo; the body may then be empty.
    XFile? image,
  });

  Future<List<FriendFilmActivity>> fetchFriendActivity(String filmId);
}
