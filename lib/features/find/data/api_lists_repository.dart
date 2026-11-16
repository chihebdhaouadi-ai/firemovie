import 'api_client.dart';
import 'lists_repository.dart';
import 'movie.dart';

/// Concrete [ListsRepository] backed by the Django `/api/lists/` endpoints.
class ApiListsRepository implements ListsRepository {
  ApiListsRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  static const _paths = {
    FilmListId.top5: '/api/lists/top5/',
    FilmListId.watched: '/api/lists/watched/',
    FilmListId.watchlist: '/api/lists/watchlist/',
  };

  @override
  Future<ListSnapshot> fetchAll() async {
    final countsJson = await _client.getJson('/api/lists/');
    final counts = <String, int>{};
    for (final list in FilmListId.values) {
      final type = listTypeOf(list);
      final value = countsJson[type];
      counts[type] = value is int
          ? value
          : value is num
              ? value.toInt()
              : 0;
    }

    final top5 = await _fetchIds(FilmListId.top5);
    final watched = await _fetchIds(FilmListId.watched);
    final watchlist = await _fetchIds(FilmListId.watchlist);

    return ListSnapshot(
      top5: top5,
      watched: watched,
      watchlist: watchlist,
      counts: counts,
    );
  }

  Future<List<String>> _fetchIds(FilmListId list) async {
    final json = await _client.getJson(_paths[list]!);
    final ids = <String>[];
    if (json['results'] case final List results) {
      for (final row in results) {
        if (row is Map<String, dynamic> && row['film_id'] is String) {
          ids.add(row['film_id'] as String);
        }
      }
    }
    return ids;
  }

  @override
  Future<ListEntry> add(
    FilmListId list,
    String filmId, {
    int? slot,
    bool replace = false,
  }) async {
    final body = <String, dynamic>{'film_id': filmId};
    if (list == FilmListId.top5) {
      if (slot != null) body['slot'] = slot;
      if (replace) body['replace'] = true;
    }
    final json = await _client.postJson(_paths[list]!, body: body);
    return _parseEntry(json);
  }

  @override
  Future<void> remove(FilmListId list, String filmId) async {
    await _client.delete('${_paths[list]}$filmId/');
  }

  @override
  Future<List<String>> membershipFlags(String filmId) async {
    final json = await _client.getJson('/api/films/$filmId/');
    return _stringList(json['in_lists']);
  }

  ListEntry _parseEntry(Map<String, dynamic> json) {
    final list = json['list_type'];
    final listType = list is String ? list : '';
    return ListEntry(
      filmId: _string(json['film_id']) ?? '',
      listType: listType,
      slot: json['slot'] is int ? (json['slot'] as int) : null,
      removedFromWatchlist: json['removed_from_watchlist'] == true,
    );
  }

  static String? _string(Object? value) => value is String
      ? value
      : value == null
          ? null
          : '$value';

  static List<String> _stringList(Object? value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return const [];
  }
}
