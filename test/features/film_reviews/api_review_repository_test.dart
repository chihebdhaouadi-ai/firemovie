import 'dart:convert';

import 'package:film_wise_mobile/features/film_reviews/data/api_review_repository.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/film_reaction.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/review_stance.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take_tag.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/topic_vote.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/vote_kind.dart';
import 'package:film_wise_mobile/features/find/data/api_client.dart';
import 'package:film_wise_mobile/features/find/data/movie.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _json = {'content-type': 'application/json'};

final _summaryBody = jsonEncode({
  'film_id': 'tt1',
  'total': 5,
  'counts': {'loved': 3, 'made_think': 2},
  'my_reaction': 'loved',
  'most_felt': [
    {'reaction': 'loved', 'count': 3},
    {'reaction': 'made_think', 'count': 2},
  ],
  'everyone_percent': 71,
  'trusted_percent': 84,
});

final _takeBody = {
  'id': 4,
  'film_id': 'tt1',
  'author_id': 2,
  'author_name': 'Ada',
  'is_mine': false,
  'reaction': 'blew_mind',
  'body': 'A slow burn.',
  'created_at': '2026-10-21T10:00:00Z',
  'votes': {'changed_my_mind': 0, 'well_argued': 3, 'disagree_but_fair': 1},
  'my_votes': ['well_argued'],
  'comment_count': 2,
  'is_most_helpful': true,
};

ApiReviewRepository _repository(
  Future<http.Response> Function(http.Request request) handler,
  List<http.Request> seen,
) {
  final client = MockClient((request) async {
    seen.add(request);
    return handler(request);
  });
  return ApiReviewRepository(client: ApiClient(httpClient: client));
}

void main() {
  test('postTopic serializes hot takes with the hot_take tag', () async {
    String? body;
    final client = MockClient((request) async {
      body = request.body;
      return http.Response(
        jsonEncode({..._takeBody, 'reaction': null, 'tag': 'hot_take'}),
        201,
        headers: _json,
      );
    });
    final repository = ApiReviewRepository(
      client: ApiClient(httpClient: client),
    );

    final take = await repository.postTopic(
      filmId: 'tt1',
      body: 'A bold opinion.',
      tag: TakeTag.hotTake,
    );

    expect(body, contains('name="film_id"\r\n\r\ntt1'));
    expect(body, contains('name="body"\r\n\r\nA bold opinion.'));
    expect(body, contains('name="tag"\r\n\r\nhot_take'));
    expect(take.tag, TakeTag.hotTake);
  });

  test('explore feed parses hot takes and their topic vote counts', () async {
    final seen = <http.Request>[];
    final repository = _repository(
      (_) async => http.Response(
        jsonEncode([
          {
            ..._takeBody,
            'reaction': null,
            'tag': 'hot_take',
            'votes': {'like': 14, 'dislike': 3},
            'my_votes': ['like'],
            'film': {
              'film_id': 'tt1',
              'title': 'A Film',
              'poster_url': 'https://example.test/poster.jpg',
            },
          },
        ]),
        200,
        headers: _json,
      ),
      seen,
    );

    final items = await repository.fetchExploreFeed();

    expect(seen.single.url.path, '/api/takes/explore/');
    expect(items.single.take.tag, TakeTag.hotTake);
    expect(items.single.take.topicVotesOf(TopicVote.like), 14);
    expect(items.single.take.topicVotesOf(TopicVote.dislike), 3);
    expect(items.single.take.myTopicVotes, {TopicVote.like});
  });

  test('fetchSummary reads the summary endpoint', () async {
    final seen = <http.Request>[];
    final repository = _repository(
      (_) async => http.Response(_summaryBody, 200, headers: _json),
      seen,
    );

    final summary = await repository.fetchSummary('tt1');

    expect(seen.single.method, 'GET');
    expect(seen.single.url.path, '/api/takes/films/tt1/summary/');
    expect(summary.myReaction, FilmReaction.loved);
    expect(summary.everyonePercent, 71);
    expect(summary.trustedPercent, 84);
    expect(summary.mostFelt.map((item) => item.reaction), [
      FilmReaction.loved,
      FilmReaction.madeThink,
    ]);
  });

  test('setReaction sends the reaction key, or null to clear it', () async {
    final seen = <http.Request>[];
    final repository = _repository(
      (_) async => http.Response(_summaryBody, 200, headers: _json),
      seen,
    );

    await repository.setReaction('tt1', FilmReaction.brokeHeart);
    await repository.setReaction('tt1', null);

    expect(seen[0].method, 'PUT');
    expect(seen[0].url.path, '/api/takes/films/tt1/reaction/');
    expect(jsonDecode(seen[0].body), {'reaction': 'broke_heart'});
    expect(jsonDecode(seen[1].body), {'reaction': null});
  });

  test('fetchTakes parses the take list', () async {
    final seen = <http.Request>[];
    final repository = _repository(
      (_) async => http.Response(jsonEncode([_takeBody]), 200, headers: _json),
      seen,
    );

    final takes = await repository.fetchTakes('tt1');

    expect(seen.single.url.path, '/api/takes/films/tt1/takes/');
    expect(takes.single.id, 4);
    expect(takes.single.authorName, 'Ada');
    expect(takes.single.reaction, FilmReaction.blewMind);
    expect(takes.single.votesOf(VoteKind.wellArgued), 3);
    expect(takes.single.hasVoted(VoteKind.wellArgued), isTrue);
    expect(takes.single.commentCount, 2);
    expect(takes.single.isMostHelpful, isTrue);
  });

  test('postTake sends the body and returns the created take', () async {
    final seen = <http.Request>[];
    final repository = _repository(
      (_) async => http.Response(
        jsonEncode(_takeBody),
        201,
        headers: _json,
      ),
      seen,
    );

    final take = await repository.postTake('tt1', body: 'A slow burn.');

    expect(seen.single.method, 'POST');
    expect(seen.single.url.path, '/api/takes/films/tt1/takes/');
    expect(jsonDecode(seen.single.body),
        {'body': 'A slow burn.', 'tag': 'review'});
    expect(take.body, 'A slow burn.');
  });

  test('postTake maps a second take to a ServerFailure with its code',
      () async {
    final repository = _repository(
      (_) async => http.Response(
        jsonEncode({
          'detail': 'You already shared a take for this film.',
          'code': 'already_posted',
        }),
        409,
        headers: _json,
      ),
      <http.Request>[],
    );

    await expectLater(
      repository.postTake('tt1', body: 'Again'),
      throwsA(
        isA<ServerFailure>().having(
          (failure) => failure.code,
          'code',
          'already_posted',
        ),
      ),
    );
  });

  test('setVote sends the vote kind and the active flag', () async {
    final seen = <http.Request>[];
    final repository = _repository(
      (_) async => http.Response(jsonEncode(_takeBody), 200, headers: _json),
      seen,
    );

    await repository.setVote(4, VoteKind.disagreeButFair, active: false);

    expect(seen.single.method, 'PUT');
    expect(
      seen.single.url.path,
      '/api/takes/takes/4/votes/disagree_but_fair/',
    );
    expect(jsonDecode(seen.single.body), {'active': false});
  });

  test('fetchComments and postComment use the take comment endpoints',
      () async {
    final seen = <http.Request>[];
    final repository = _repository((request) async {
      if (request.method == 'GET') {
        return http.Response(
          jsonEncode([
            {
              'id': 9,
              'author_id': 3,
              'author_name': 'Grace',
              'body': 'Agreed.',
              'created_at': '2026-10-21T11:00:00Z',
              'is_writer': true,
              'stance': 'changed_my_mind',
            },
          ]),
          200,
          headers: _json,
        );
      }
      return http.Response(
        jsonEncode({
          'id': 10,
          'author_id': 1,
          'author_name': 'Me',
          'body': 'Thanks.',
          'created_at': '2026-10-21T12:00:00Z',
          'is_writer': false,
          'stance': 'disagree_but_fair',
        }),
        201,
        headers: _json,
      );
    }, seen);

    final comments = await repository.fetchComments(4);
    final comment = await repository.postComment(
      4,
      body: 'Thanks.',
      stance: ReviewStance.disagreeButFair,
    );

    expect(seen[0].url.path, '/api/takes/takes/4/comments/');
    expect(comments.single.isWriter, isTrue);
    expect(comments.single.stance, ReviewStance.changedMyMind);
    expect(seen[1].method, 'POST');
    expect(jsonDecode(seen[1].body), {
      'body': 'Thanks.',
      'stance': 'disagree_but_fair',
    });
    expect(comment.id, 10);
    expect(comment.stance, ReviewStance.disagreeButFair);
  });

  test('a reply carries its parent id through the comment round trip',
      () async {
    final seen = <http.Request>[];
    final repository = _repository((request) async {
      if (request.method == 'GET') {
        return http.Response(
          jsonEncode([
            {
              'id': 9,
              'author_id': 3,
              'author_name': 'Grace',
              'body': 'Agreed.',
              'created_at': '2026-10-21T11:00:00Z',
              'is_writer': false,
              'parent_id': null,
            },
            {
              'id': 11,
              'author_id': 4,
              'author_name': 'Hugo',
              'body': 'Me too.',
              'created_at': '2026-10-21T11:30:00Z',
              'is_writer': false,
              'parent_id': 9,
            },
          ]),
          200,
          headers: _json,
        );
      }
      return http.Response(
        jsonEncode({
          'id': 12,
          'author_id': 1,
          'author_name': 'Me',
          'body': 'Thanks.',
          'created_at': '2026-10-21T12:00:00Z',
          'is_writer': false,
          'parent_id': 9,
        }),
        201,
        headers: _json,
      );
    }, seen);

    final comments = await repository.fetchComments(4);
    final reply = await repository.postComment(4, body: 'Thanks.', parentId: 9);

    expect(comments[0].parentId, isNull);
    expect(comments[1].parentId, 9);
    expect(comments[1].createdAt, DateTime.utc(2026, 10, 21, 11, 30));
    expect(jsonDecode(seen[1].body), {'body': 'Thanks.', 'parent_id': 9});
    expect(reply.parentId, 9);
  });

  test('an unknown reaction from the server is a bad response', () async {
    final repository = _repository(
      (_) async => http.Response(
        jsonEncode({
          ..._takeBody,
          'reaction': 'confused',
        }),
        200,
        headers: _json,
      ),
      <http.Request>[],
    );

    await expectLater(
      repository.postTake('tt1', body: 'Hmm'),
      throwsA(
        isA<ServerFailure>().having(
          (failure) => failure.code,
          'code',
          'bad_response',
        ),
      ),
    );
  });

  test('setCommentVote puts the vote and parses the new counts', () async {
    final seen = <http.Request>[];
    final repository = _repository((request) async {
      return http.Response(
        jsonEncode({
          'id': 9,
          'author_id': 3,
          'author_name': 'Grace',
          'body': 'Agreed.',
          'created_at': '2026-10-21T11:00:00Z',
          'is_writer': false,
          'is_mine': false,
          'likes': 4,
          'dislikes': 1,
          'my_vote': 'like',
        }),
        200,
        headers: _json,
      );
    }, seen);

    final comment =
        await repository.setCommentVote(9, TopicVote.like, active: true);

    expect(seen.single.method, 'PUT');
    expect(seen.single.url.path, '/api/takes/comments/9/votes/like/');
    expect(jsonDecode(seen.single.body), {'active': true});
    expect(comment.likes, 4);
    expect(comment.dislikes, 1);
    expect(comment.myVote, TopicVote.like);
    expect(comment.isMine, isFalse);
  });
}
