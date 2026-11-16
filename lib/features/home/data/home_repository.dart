import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/api_config.dart';
import '../../../core/session.dart';
import '../../film_reviews/data/api_review_repository.dart';
import '../../film_reviews/data/review_repository.dart';
import '../../film_reviews/domain/take.dart';
import 'home_models.dart';

abstract class HomeRepository {
  Future<List<Film>> fetch(HomeList list);

  Future<void> add(HomeList list, Film film);

  Future<void> remove(HomeList list, Film film);

  Future<List<FeedItem>> fetchFeed(List<Film> films);
}

abstract class PointsGateway {
  Future<int> fetchPoints();
}

class ApiHomeRepository implements HomeRepository {
  ApiHomeRepository({
    http.Client? client,
    String? baseUrl,
    ReviewRepository? reviews,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? '${ApiConfig.baseUrl}/api/film/',
        _reviews = reviews ?? ApiReviewRepository();

  final http.Client _client;
  final String _baseUrl;
  final ReviewRepository _reviews;

  @override
  Future<List<Film>> fetch(HomeList list) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl${_fetchPath(list)}'),
      headers: _headers,
    );
    final body = _decode(response);
    final data = body['data'];
    if (data is! List) {
      throw const HomeDataException('Unexpected response shape');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map((item) => Film(
              imdbId: '${item['imdp_id']}',
              title: item['title'] as String?,
              posterUrl: item['poster_url'] as String?,
            ))
        .toList(growable: false);
  }

  @override
  Future<void> add(HomeList list, Film film) async {
    final path = switch (list) {
      HomeList.top5 => 'add_top_5_movies',
      HomeList.watched => 'add_watched_movies',
      HomeList.watchlist => 'add_watchlist_movies',
      HomeList.popular => throw const HomeDataException('Popular is read-only'),
    };
    _decode(await _post(path, film));
  }

  @override
  Future<void> remove(HomeList list, Film film) async {
    final path = switch (list) {
      HomeList.top5 => 'delete_top_5_movies',
      HomeList.watched => 'delete_wathced_list_movies',
      HomeList.watchlist => 'delete_watch_list_movies',
      HomeList.popular => throw const HomeDataException('Popular is read-only'),
    };
    _decode(await _post(path, film));
  }

  @override
  Future<List<FeedItem>> fetchFeed(List<Film> films) async {
    if (films.isEmpty) return const [];
    var failures = 0;
    final results = await Future.wait([
      for (final film in films)
        _reviews.fetchTakes(film.imdbId).catchError((Object _) {
          failures++;
          return const <Take>[];
        }),
    ]);
    if (failures == films.length) {
      throw const HomeDataException('Feed unavailable');
    }
    final items = [
      for (var i = 0; i < films.length; i++)
        for (final take in results[i])
          if (!take.isMine) FeedItem(film: films[i], take: take),
    ];
    items.sort(_compareFeedItems);
    return items.take(HomeLimits.feedTakeLimit).toList(growable: false);
  }

  static int _compareFeedItems(FeedItem a, FeedItem b) {
    final helpful =
        (b.take.isMostHelpful ? 1 : 0) - (a.take.isMostHelpful ? 1 : 0);
    if (helpful != 0) return helpful;
    return b.take.totalVotes.compareTo(a.take.totalVotes);
  }

  Future<http.Response> _post(String path, Film film) {
    return _client.post(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
      body: {'imdbid': film.imdbId},
    );
  }

  /// No Authorization header for guests. A bare 'Token ' value is malformed.
  Map<String, String> get _headers => {
        if (ApiConfig.authorization case final auth?) 'Authorization': auth,
      };

  String _fetchPath(HomeList list) => switch (list) {
        HomeList.top5 => 'get_top_5_movies',
        HomeList.watched => 'get_wathced_list_movies',
        HomeList.watchlist => 'get_watch_list_movies',
        HomeList.popular => 'get_popular_friends_list_movies',
      };

  Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode == 401) Session.reportUnauthorized();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HomeDataException('HTTP ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const HomeDataException('Unexpected response shape');
    }
    return decoded;
  }
}

// FAKE: in-memory list store for widget tests and offline previews. Not wired
// to any server.
class FakeHomeRepository implements HomeRepository {
  FakeHomeRepository({Map<HomeList, List<Film>>? seed, this.feed = const []})
      : _lists = {
          HomeList.top5: <Film>[],
          HomeList.watched: <Film>[],
          HomeList.watchlist: <Film>[],
          HomeList.popular: <Film>[],
          ...?seed,
        };

  final Map<HomeList, List<Film>> _lists;
  final List<FeedItem> feed;

  @override
  Future<List<Film>> fetch(HomeList list) async =>
      List.unmodifiable(_lists[list] ?? const <Film>[]);

  @override
  Future<void> add(HomeList list, Film film) async {
    if (list == HomeList.popular) {
      throw const HomeDataException('Popular is read-only');
    }
    final items = _lists[list]!;
    if (!items.contains(film)) items.add(film);
  }

  @override
  Future<void> remove(HomeList list, Film film) async {
    _lists[list]?.remove(film);
  }

  @override
  Future<List<FeedItem>> fetchFeed(List<Film> films) async =>
      feed.where((item) => films.contains(item.film)).toList(growable: false);
}

// FAKE: the backend has no points endpoint yet. Points stay at zero.
class FakePointsGateway implements PointsGateway {
  @override
  Future<int> fetchPoints() async => 0;
}
