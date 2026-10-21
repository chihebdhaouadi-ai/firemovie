import '../domain/film_reaction.dart';
import '../domain/movie_review_summary.dart';
import '../domain/take.dart';
import '../domain/vote_kind.dart';

abstract interface class ReviewRepository {
  Future<MovieReviewSummary> fetchSummary(String filmId);

  Future<MovieReviewSummary> setReaction(String filmId, FilmReaction? reaction);

  Future<List<Take>> fetchTakes(String filmId);

  Future<Take> postTake(String filmId, {required String body});

  Future<Take> setVote(int takeId, VoteKind kind, {required bool active});

  Future<List<TakeComment>> fetchComments(int takeId);

  Future<TakeComment> postComment(int takeId, {required String body});
}
