import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/session.dart';
import 'home_models.dart';

abstract class HomeRepository {
  Future<List<Film>> fetch(HomeList list);

  Future<void> add(HomeList list, Film film);

  Future<void> remove(HomeList list, Film film);
}

abstract class RecommendationGateway {
  Future<int> fetchPoints();

  Future<int> generate(List<Film> picks);
}

class ApiHomeRepository implements HomeRepository {
  ApiHomeRepository({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? _defaultBaseUrl;

  static const _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/film/',
  );

  final http.Client _client;
  final String _baseUrl;

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
        .map((item) => Film(imdbId: '${item['imdp_id']}'))
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

  Future<http.Response> _post(String path, Film film) {
    return _client.post(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
      body: {'imdbid': film.imdbId},
    );
  }

  Map<String, String> get _headers => {
    'Authorization': 'Token ${Session.token}',
  };

  String _fetchPath(HomeList list) => switch (list) {
    HomeList.top5 => 'get_top_5_movies',
    HomeList.watched => 'get_wathced_list_movies',
    HomeList.watchlist => 'get_watch_list_movies',
    HomeList.popular => 'get_popular_friends_list_movies',
  };

  Map<String, dynamic> _decode(http.Response response) {
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
  FakeHomeRepository({Map<HomeList, List<Film>>? seed})
    : _lists = {
        HomeList.top5: <Film>[],
        HomeList.watched: <Film>[],
        HomeList.watchlist: <Film>[],
        HomeList.popular: <Film>[],
        ...?seed,
      };

  final Map<HomeList, List<Film>> _lists;

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
}

// FAKE: the backend has no points or recommendation endpoint yet. Points start
// at zero and each GENERATE adds HomeLimits.pointsPerGenerate locally.
class FakeRecommendationGateway implements RecommendationGateway {
  int _points = 0;

  @override
  Future<int> fetchPoints() async => _points;

  @override
  Future<int> generate(List<Film> picks) async {
    _points += HomeLimits.pointsPerGenerate;
    return _points;
  }
}
