import 'dart:convert';

import 'package:film_wise_mobile/features/film_reviews/data/review_repository.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/film_reaction.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/movie_review_summary.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/review_stance.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take_skin.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take_tag.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/topic_vote.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/vote_kind.dart';
import 'package:film_wise_mobile/features/home/data/home_models.dart';
import 'package:film_wise_mobile/features/home/data/home_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http/testing.dart';

const _a = Film(imdbId: 'tt0000001', title: 'Dune');
const _b = Film(imdbId: 'tt0000002', title: 'Arrival');

Take _take(
  int id, {
  bool mine = false,
  bool helpful = false,
  int votes = 0,
}) {
  return Take(
    id: id,
    authorId: id,
    authorName: 'user$id',
    isMine: mine,
    reaction: FilmReaction.blewMind,
    body: 'take $id',
    votes: votes == 0 ? const {} : {VoteKind.values.first: votes},
    myVotes: const {},
    commentCount: 0,
    isMostHelpful: helpful,
  );
}

class _FakeReviews implements ReviewRepository {
  _FakeReviews(this.takesByFilm, {this.failing = const {}});

  final Map<String, List<Take>> takesByFilm;
  final Set<String> failing;

  @override
  Future<List<Take>> fetchTakes(String filmId) async {
    if (failing.contains(filmId)) throw Exception('offline');
    return takesByFilm[filmId] ?? const [];
  }

  @override
  Future<MovieReviewSummary> fetchSummary(String filmId) =>
      throw UnimplementedError();

  @override
  Future<MovieReviewSummary> setReaction(
    String filmId,
    FilmReaction? reaction,
  ) =>
      throw UnimplementedError();

  @override
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
  }) =>
      throw UnimplementedError();

  @override
  Future<Take> setPollVote(int takeId, int optionId) =>
      throw UnimplementedError();

  @override
  Future<Take> postTake(
    String filmId, {
    required String body,
    TakeTag tag = TakeTag.review,
    TakeSkin skin = TakeSkin.normal,
    bool spoiler = false,
  }) =>
      throw UnimplementedError();

  @override
  Future<List<FeedItem>> fetchExploreFeed() => throw UnimplementedError();

  @override
  Future<List<FeedItem>> fetchTrendingTopics() => throw UnimplementedError();

  @override
  Future<List<FeedItem>> fetchFriendTakes() => throw UnimplementedError();

  @override
  Future<List<FeedItem>> fetchMyTakes() => throw UnimplementedError();

  @override
  Future<Take> setVote(int takeId, VoteKind kind, {required bool active}) =>
      throw UnimplementedError();

  @override
  Future<Take> setTopicVote(int takeId, TopicVote kind,
          {required bool active}) =>
      throw UnimplementedError();

  @override
  Future<Take> setSaved(int takeId, {required bool active}) =>
      throw UnimplementedError();

  @override
  Future<List<FeedItem>> fetchSavedTakes() => throw UnimplementedError();

  @override
  Future<List<TakeComment>> fetchComments(int takeId) =>
      throw UnimplementedError();

  @override
  Future<TakeComment> setCommentVote(
    int commentId,
    TopicVote kind, {
    required bool active,
  }) =>
      throw UnimplementedError();

  @override
  Future<TakeComment> postComment(
    int takeId, {
    required String body,
    int? parentId,
    ReviewStance? stance,
    XFile? image,
  }) =>
      throw UnimplementedError();

  @override
  Future<List<FriendFilmActivity>> fetchFriendActivity(String filmId) =>
      throw UnimplementedError();
}

ApiHomeRepository _repository(_FakeReviews reviews) => ApiHomeRepository(
      client: MockClient((_) async => http.Response('', 500)),
      baseUrl: 'http://test/api/film/',
      reviews: reviews,
    );

void main() {
  test('fetch maps title and poster from each list entry', () async {
    final client = MockClient((request) async {
      expect(request.url.path, endsWith('get_top_5_movies'));
      return http.Response(
        jsonEncode({
          'data': [
            {
              'imdp_id': 'tt0111161',
              'title': 'The Shawshank Redemption',
              'poster_url': 'https://img/p.jpg',
            },
            {'imdp_id': 'tt0068646', 'title': null, 'poster_url': null},
          ],
          'status': 200,
        }),
        200,
      );
    });
    final repository = ApiHomeRepository(
      client: client,
      baseUrl: 'http://test/api/film/',
    );

    final films = await repository.fetch(HomeList.top5);

    expect(films, const [
      Film(
        imdbId: 'tt0111161',
        title: 'The Shawshank Redemption',
        posterUrl: 'https://img/p.jpg',
      ),
      Film(imdbId: 'tt0068646'),
    ]);
  });

  group('fetchFeed', () {
    test('returns nothing without asking for takes when there are no films',
        () async {
      final repository = _repository(_FakeReviews({}));

      expect(await repository.fetchFeed(const []), isEmpty);
    });

    test('merges takes from several films, each tagged with its film',
        () async {
      final repository = _repository(
        _FakeReviews({
          _a.imdbId: [_take(1)],
          _b.imdbId: [_take(2)],
        }),
      );

      final items = await repository.fetchFeed(const [_a, _b]);

      expect(items.map((item) => (item.film, item.take.id)), [
        (_a, 1),
        (_b, 2),
      ]);
    });

    test("excludes the user's own takes", () async {
      final repository = _repository(
        _FakeReviews({
          _a.imdbId: [_take(1, mine: true), _take(2)],
        }),
      );

      final items = await repository.fetchFeed(const [_a]);

      expect(items.map((item) => item.take.id), [2]);
    });

    test('ranks most helpful first, then by total votes', () async {
      final repository = _repository(
        _FakeReviews({
          _a.imdbId: [
            _take(1, votes: 1),
            _take(2, helpful: true),
            _take(3, votes: 9),
          ],
        }),
      );

      final items = await repository.fetchFeed(const [_a]);

      expect(items.map((item) => item.take.id), [2, 3, 1]);
    });

    test('caps the feed at the configured take limit', () async {
      final repository = _repository(
        _FakeReviews({
          _a.imdbId: [
            for (var id = 1; id <= HomeLimits.feedTakeLimit + 5; id++)
              _take(id),
          ],
        }),
      );

      final items = await repository.fetchFeed(const [_a]);

      expect(items, hasLength(HomeLimits.feedTakeLimit));
    });

    test('keeps the films that load when one film fails', () async {
      final repository = _repository(
        _FakeReviews(
          {
            _b.imdbId: [_take(2)],
          },
          failing: {_a.imdbId},
        ),
      );

      final items = await repository.fetchFeed(const [_a, _b]);

      expect(items.map((item) => item.film), [_b]);
    });

    test('throws when every film fails to load', () async {
      final repository = _repository(
        _FakeReviews({}, failing: {_a.imdbId, _b.imdbId}),
      );

      expect(
        () => repository.fetchFeed(const [_a, _b]),
        throwsA(isA<HomeDataException>()),
      );
    });
  });
}
