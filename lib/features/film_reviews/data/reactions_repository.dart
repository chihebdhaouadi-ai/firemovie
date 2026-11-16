import '../../find/data/api_client.dart';
import '../domain/film_reaction.dart';
import '../domain/movie_review_summary.dart';
import 'review_parser.dart';

/// Saves the viewer's feelings for a film (up to
/// [MovieReviewSummary.maxFeelings]). Kept apart from ReviewRepository so the
/// many review fakes do not all need a new method.
abstract interface class ReactionsRepository {
  /// Replaces the viewer's feelings (empty clears them) and returns the
  /// updated summary.
  Future<MovieReviewSummary> setFeelings(
    String filmId,
    List<FilmReaction> feelings,
  );
}

class ApiReactionsRepository implements ReactionsRepository {
  ApiReactionsRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<MovieReviewSummary> setFeelings(
    String filmId,
    List<FilmReaction> feelings,
  ) async {
    return ReviewParser.summary(
      await _client.putJson(
        '/api/takes/films/$filmId/reaction/',
        body: {
          'reactions': [for (final feeling in feelings) feeling.apiValue],
        },
      ),
    );
  }
}

/// In-memory [ReactionsRepository] for tests; records each save.
class FakeReactionsRepository implements ReactionsRepository {
  FakeReactionsRepository({this.fail = false});

  bool fail;
  final saves = <List<FilmReaction>>[];

  @override
  Future<MovieReviewSummary> setFeelings(
    String filmId,
    List<FilmReaction> feelings,
  ) async {
    saves.add(List.of(feelings));
    if (fail) throw Exception('save failed');
    return MovieReviewSummary(
      myReaction: feelings.isEmpty ? null : feelings.first,
      myReactions: List.of(feelings),
      mostFelt: [
        for (final feeling in feelings)
          ReactionCount(reaction: feeling, count: 1),
      ],
      everyonePercent: null,
      trustedPercent: null,
      total: feelings.isEmpty ? 0 : 1,
    );
  }
}
