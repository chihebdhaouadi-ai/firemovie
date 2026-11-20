import 'package:image_picker/image_picker.dart';

import '../../film_reviews/data/api_review_repository.dart' show topicImageType;
import '../../find/data/api_client.dart';
import 'movie_list.dart';

/// Lists people make and post, with hearts and comments.
abstract class MovieListRepository {
  Future<List<MovieList>> fetchMine();
  Future<List<MovieList>> fetchFriends();
  Future<MovieList> fetchList(int id);
  Future<MovieList> create(String name, List<ListFilm> films);

  /// Renames a list you own and replaces its films.
  Future<MovieList> update(int id, String name, List<ListFilm> films);
  Future<void> delete(int id);
  Future<MovieList> setLike(int id, {required bool active});

  /// Saves someone else's list to your profile, or takes it off.
  Future<MovieList> setSaved(int id, {required bool active});

  /// Lists you saved, the last saved first.
  Future<List<MovieList>> fetchSaved();

  /// Sends a list into your chat with each friend picked; returns how many.
  Future<int> share(int id,
      {required List<int> recipientIds, String message = ''});
  Future<List<ListComment>> fetchComments(int id);

  /// Posts a comment with text, a photo or both; [parentId] makes it a reply.
  Future<ListComment> postComment(
    int id, {
    String body = '',
    int? parentId,
    XFile? image,
  });
}

class ApiMovieListRepository implements MovieListRepository {
  ApiMovieListRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;
  static const _base = '/api/movie-lists/';

  List<Map<String, dynamic>> _rows(Map<String, dynamic> body) => [
        for (final row in body['data'] as List? ?? const [])
          if (row is Map) row.cast<String, dynamic>(),
      ];

  @override
  Future<List<MovieList>> fetchMine() async =>
      _rows(await _client.getJson(_base)).map(MovieList.fromJson).toList();

  @override
  Future<List<MovieList>> fetchFriends() async =>
      _rows(await _client.getJson('${_base}friends/'))
          .map(MovieList.fromJson)
          .toList();

  @override
  Future<MovieList> fetchList(int id) async =>
      MovieList.fromJson(await _client.getJson('$_base$id/'));

  @override
  Future<MovieList> create(String name, List<ListFilm> films) async =>
      MovieList.fromJson(await _client.postJson(_base, body: {
        'name': name,
        'films': [for (final film in films) film.toJson()],
      }));

  @override
  Future<MovieList> update(int id, String name, List<ListFilm> films) async =>
      MovieList.fromJson(await _client.patchJson('$_base$id/', body: {
        'name': name,
        'films': [for (final film in films) film.toJson()],
      }));

  @override
  Future<void> delete(int id) => _client.delete('$_base$id/');

  @override
  Future<MovieList> setSaved(int id, {required bool active}) async =>
      MovieList.fromJson(
        await _client.putJson('$_base$id/save/', body: {'active': active}),
      );

  @override
  Future<int> share(int id,
      {required List<int> recipientIds, String message = ''}) async {
    final body = await _client.postJson('$_base$id/share/', body: {
      'recipient_ids': recipientIds,
      'message': message,
    });
    return body['sent'] as int? ?? recipientIds.length;
  }

  @override
  Future<List<MovieList>> fetchSaved() async =>
      _rows(await _client.getJson('${_base}saved/'))
          .map(MovieList.fromJson)
          .toList();

  @override
  Future<MovieList> setLike(int id, {required bool active}) async =>
      MovieList.fromJson(
        await _client.putJson('$_base$id/like/', body: {'active': active}),
      );

  @override
  Future<List<ListComment>> fetchComments(int id) async =>
      _rows(await _client.getJson('$_base$id/comments/'))
          .map(ListComment.fromJson)
          .toList();

  @override
  Future<ListComment> postComment(
    int id, {
    String body = '',
    int? parentId,
    XFile? image,
  }) async {
    if (image != null) {
      return ListComment.fromJson(await _client.postMultipart(
        '$_base$id/comments/',
        fields: {
          'body': body,
          if (parentId != null) 'parent_id': '$parentId',
        },
        file: image,
        fileType: topicImageType(image),
      ));
    }
    return ListComment.fromJson(await _client.postJson(
      '$_base$id/comments/',
      body: {'body': body, if (parentId != null) 'parent_id': parentId},
    ));
  }
}

// FAKE: in-memory lists for widget tests and offline previews. Not wired to
// any server.
class FakeMovieListRepository implements MovieListRepository {
  FakeMovieListRepository({
    List<MovieList> mine = const [],
    List<MovieList> friends = const [],
    this.me = const ListPerson(id: 1, username: 'me'),
  })  : _mine = [...mine],
        _friends = [...friends];

  final ListPerson me;
  final List<MovieList> _mine;
  final List<MovieList> _friends;
  final Map<int, List<ListComment>> _comments = {};
  int _nextId = 1000;

  MovieList _find(int id) =>
      [..._mine, ..._friends].firstWhere((list) => list.id == id);

  void _replace(MovieList list) {
    for (final lists in [_mine, _friends]) {
      final i = lists.indexWhere((l) => l.id == list.id);
      if (i >= 0) lists[i] = list;
    }
  }

  @override
  Future<List<MovieList>> fetchMine() async => List.of(_mine);

  @override
  Future<List<MovieList>> fetchFriends() async => List.of(_friends);

  @override
  Future<MovieList> fetchList(int id) async => _find(id);

  @override
  Future<MovieList> create(String name, List<ListFilm> films) async {
    final list = MovieList(
      id: _nextId++,
      name: name,
      owner: me,
      isMine: true,
      filmCount: films.length,
      posters: [
        for (final film in films)
          if (film.posterUrl case final poster?) poster,
      ].take(4).toList(),
      films: films,
    );
    _mine.insert(0, list);
    return list;
  }

  @override
  Future<MovieList> update(int id, String name, List<ListFilm> films) async {
    final updated = _find(id).copyWith(name: name, films: films);
    _replace(updated);
    return updated;
  }

  @override
  Future<void> delete(int id) async => _mine.removeWhere((l) => l.id == id);

  @override
  Future<MovieList> setSaved(int id, {required bool active}) async {
    final updated = _find(id).copyWith(saved: active);
    _replace(updated);
    return updated;
  }

  /// Who each list was sent to, by list id (for tests).
  final Map<int, List<int>> shares = {};

  @override
  Future<int> share(int id,
      {required List<int> recipientIds, String message = ''}) async {
    (shares[id] ??= []).addAll(recipientIds);
    return recipientIds.length;
  }

  @override
  Future<List<MovieList>> fetchSaved() async =>
      [..._friends, ..._mine].where((list) => list.saved).toList();

  @override
  Future<MovieList> setLike(int id, {required bool active}) async {
    final current = _find(id);
    if (current.liked == active) return current;
    final updated = current.copyWith(
      liked: active,
      likes: current.likes + (active ? 1 : -1),
    );
    _replace(updated);
    return updated;
  }

  @override
  Future<List<ListComment>> fetchComments(int id) async =>
      List.of(_comments[id] ?? const []);

  @override
  Future<ListComment> postComment(
    int id, {
    String body = '',
    int? parentId,
    XFile? image,
  }) async {
    final comment = ListComment(
      id: _nextId++,
      author: me,
      body: body,
      createdAt: DateTime.now(),
      parentId: parentId,
      imageUrl: image == null ? null : 'https://img.test/${image.name}',
      isWriter: _find(id).isMine,
      isMine: true,
    );
    (_comments[id] ??= []).add(comment);
    final current = _find(id);
    _replace(current.copyWith(comments: current.comments + 1));
    return comment;
  }
}
