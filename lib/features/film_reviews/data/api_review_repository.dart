import '../../find/data/api_client.dart';
import '../domain/film_reaction.dart';
import '../domain/movie_review_summary.dart';
import '../domain/take.dart';
import '../domain/vote_kind.dart';
import 'review_parser.dart';
import 'review_repository.dart';

class ApiReviewRepository implements ReviewRepository {
  ApiReviewRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<MovieReviewSummary> fetchSummary(String filmId) async {
    return ReviewParser.summary(
      await _client.getJson('/api/takes/films/$filmId/summary/'),
    );
  }

  @override
  Future<MovieReviewSummary> setReaction(
    String filmId,
    FilmReaction? reaction,
  ) async {
    return ReviewParser.summary(
      await _client.putJson(
        '/api/takes/films/$filmId/reaction/',
        body: {'reaction': reaction?.apiValue},
      ),
    );
  }

  @override
  Future<List<Take>> fetchTakes(String filmId) async {
    return ReviewParser.takes(
      await _client.getList('/api/takes/films/$filmId/takes/'),
    );
  }

  @override
  Future<Take> postTake(String filmId, {required String body}) async {
    return ReviewParser.take(
      await _client.postJson(
        '/api/takes/films/$filmId/takes/',
        body: {'body': body},
      ),
    );
  }

  @override
  Future<Take> setVote(int takeId, VoteKind kind, {required bool active}) async {
    return ReviewParser.take(
      await _client.putJson(
        '/api/takes/takes/$takeId/votes/${kind.apiValue}/',
        body: {'active': active},
      ),
    );
  }

  @override
  Future<List<TakeComment>> fetchComments(int takeId) async {
    return ReviewParser.comments(
      await _client.getList('/api/takes/takes/$takeId/comments/'),
    );
  }

  @override
  Future<TakeComment> postComment(int takeId, {required String body}) async {
    return ReviewParser.comment(
      await _client.postJson(
        '/api/takes/takes/$takeId/comments/',
        body: {'body': body},
      ),
    );
  }
}
