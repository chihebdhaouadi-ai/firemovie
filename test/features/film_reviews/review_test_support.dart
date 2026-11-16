import 'dart:convert';

import 'package:film_wise_mobile/features/film_reviews/data/api_review_repository.dart';
import 'package:film_wise_mobile/features/find/data/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const jsonHeaders = {'content-type': 'application/json'};

http.Response jsonResponse(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status, headers: jsonHeaders);

ApiReviewRepository reviewRepositoryFor(http.Client client) =>
    ApiReviewRepository(client: ApiClient(httpClient: client));

Map<String, Object?> summaryJson({String? myReaction}) {
  return {
    'film_id': 'tt1',
    'total': 6,
    'counts': {
      'loved': 4,
      'broke_heart': 0,
      'blew_mind': 0,
      'made_cry': 0,
      'shocked': 0,
      'made_laugh': 0,
      'bored': 0,
      'disappointed': 0,
      'made_think': 0,
      'masterpiece': 2,
    },
    'my_reaction': myReaction,
    'most_felt': [
      {'reaction': 'loved', 'count': 4},
      {'reaction': 'masterpiece', 'count': 2},
    ],
    'everyone_percent': 71,
    'trusted_percent': 84,
  };
}

Map<String, Object?> takeJson({
  int id = 1,
  String authorName = 'leo',
  bool isMine = false,
  bool isMostHelpful = false,
  String body = 'Great film',
  int wellArgued = 3,
  List<String> myVotes = const [],
  int commentCount = 2,
}) {
  return {
    'id': id,
    'film_id': 'tt1',
    'author_id': id + 100,
    'author_name': authorName,
    'is_mine': isMine,
    'reaction': 'loved',
    'body': body,
    'created_at': '2026-01-01T12:00:00Z',
    'votes': {
      'changed_my_mind': 0,
      'well_argued': wellArgued,
      'disagree_but_fair': 0,
    },
    'my_votes': myVotes,
    'comment_count': commentCount,
    'is_most_helpful': isMostHelpful,
  };
}

Map<String, Object?> commentJson({
  int id = 9,
  String authorName = 'maya',
  int authorId = 5,
  String body = 'Agreed',
  bool isWriter = false,
  int? parentId,
}) {
  return {
    'id': id,
    'author_id': authorId,
    'author_name': authorName,
    'parent_id': parentId,
    'body': body,
    'created_at': '2026-01-01T13:00:00Z',
    'is_writer': isWriter,
  };
}

/// Routes /api/takes/ requests against in-memory state shaped like the backend contract.
/// Add a key to [failing] to make that route answer with a 500.
class ReviewApi {
  ReviewApi({
    Map<String, Object?>? summary,
    List<Map<String, Object?>>? takes,
    List<Map<String, Object?>>? friends,
  })  : summary = summary ?? summaryJson(),
        takes = takes ?? [],
        friends = friends ?? [];

  Map<String, Object?> summary;
  List<Map<String, Object?>> takes;
  List<Map<String, Object?>> friends;
  final List<Map<String, Object?>> comments = [];
  final Set<String> failing = {};
  final List<http.Request> requests = [];

  late final http.Client client = MockClient(handle);

  Future<http.Response> handle(http.Request request) async {
    requests.add(request);
    final path = request.url.path;
    final body = request.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(request.body) as Map<String, dynamic>;

    if (path.endsWith('/summary/')) {
      return failing.contains('summary') ? _down() : jsonResponse(summary);
    }
    if (path.endsWith('/reaction/')) {
      if (failing.contains('reaction')) return _down();
      summary = summaryJson(myReaction: body['reaction'] as String?);
      return jsonResponse(summary);
    }
    final vote =
        RegExp(r'/api/takes/takes/(\d+)/votes/(\w+)/$').firstMatch(path);
    if (vote != null) {
      return _vote(
        int.parse(vote.group(1)!),
        vote.group(2)!,
        body['active'] as bool,
      );
    }
    final comment = RegExp(r'/api/takes/takes/\d+/comments/$').hasMatch(path);
    if (comment) {
      if (request.method == 'POST') {
        return _postComment(
          body['body'] as String,
          parentId: body['parent_id'] as int?,
        );
      }
      return failing.contains('comments') ? _down() : jsonResponse(comments);
    }
    if (path.endsWith('/takes/')) {
      if (request.method == 'POST') return _postTake(body['body'] as String);
      return failing.contains('takes') ? _down() : jsonResponse(takes);
    }
    if (path.endsWith('/friends/')) {
      return failing.contains('friends') ? _down() : jsonResponse(friends);
    }
    return http.Response('not found', 404);
  }

  http.Response _down() => http.Response('unavailable', 500);

  http.Response _vote(int takeId, String kind, bool active) {
    if (failing.contains('vote')) return _down();
    final index = takes.indexWhere((take) => take['id'] == takeId);
    if (index < 0) return http.Response('not found', 404);
    final take = Map<String, Object?>.of(takes[index]);
    final votes =
        Map<String, Object?>.of(take['votes']! as Map<String, Object?>);
    final mine = (take['my_votes']! as List).cast<String>().toList();
    final had = mine.contains(kind);
    if (active && !had) {
      mine.add(kind);
      votes[kind] = (votes[kind]! as int) + 1;
    } else if (!active && had) {
      mine.remove(kind);
      votes[kind] = (votes[kind]! as int) - 1;
    }
    take
      ..['votes'] = votes
      ..['my_votes'] = mine;
    takes[index] = take;
    return jsonResponse(take);
  }

  http.Response _postTake(String body) {
    if (failing.contains('postTake')) {
      return jsonResponse(
        {
          'detail': 'You already shared a take for this film.',
          'code': 'already_posted'
        },
        409,
      );
    }
    final take = takeJson(
      id: 50 + takes.length,
      authorName: 'Me',
      isMine: true,
      body: body,
    );
    takes.insert(0, take);
    return jsonResponse(take, 201);
  }

  http.Response _postComment(String body, {int? parentId}) {
    if (failing.contains('postComment')) return _down();
    final comment = commentJson(
      id: 20 + comments.length,
      authorName: 'Me',
      body: body,
      parentId: parentId,
    );
    comments.add(comment);
    return jsonResponse(comment, 201);
  }
}
