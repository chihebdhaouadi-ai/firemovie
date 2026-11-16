import 'dart:convert';

import 'package:film_wise_mobile/features/film_reviews/data/api_review_repository.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take_tag.dart';
import 'package:film_wise_mobile/features/find/data/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Map<String, dynamic> _takeBody({Map<String, dynamic> extra = const {}}) => {
      'id': 7,
      'author_id': 2,
      'author_name': 'Ada',
      'is_mine': false,
      'reaction': null,
      'body': 'Best Nolan film?',
      'tag': 'poll',
      'votes': const <String, int>{},
      'my_votes': const <String>[],
      'comment_count': 0,
      'is_most_helpful': false,
      ...extra,
    };

void main() {
  test('setPollVote posts the option to the poll endpoint and parses the take',
      () async {
    late http.Request sent;
    final client = MockClient((request) async {
      sent = request;
      return http.Response(
        jsonEncode(_takeBody(extra: {
          'poll_options': [
            {'id': 1, 'label': 'Memento', 'votes': 2},
            {'id': 3, 'label': 'Interstellar', 'votes': 5},
          ],
          'my_poll_option_id': 3,
        })),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final repository = ApiReviewRepository(
      client: ApiClient(httpClient: client),
    );

    final take = await repository.setPollVote(7, 3);

    expect(sent.method, 'POST');
    expect(sent.url.path, '/api/takes/takes/7/poll/');
    expect(jsonDecode(sent.body), {'option_id': 3});
    expect(take.myPollOptionId, 3);
    expect(take.totalPollVotes, 7);
  });

  test(
      'postTopic sends each poll option as a repeated field and the scene fields',
      () async {
    String? body;
    final client = MockClient((request) async {
      body = request.body;
      return http.Response(jsonEncode(_takeBody()), 201,
          headers: {'content-type': 'application/json'});
    });
    final repository = ApiReviewRepository(
      client: ApiClient(httpClient: client),
    );

    await repository.postTopic(
      body: 'Best Nolan film?',
      tag: TakeTag.poll,
      options: const ['Memento', 'Inception'],
    );

    expect(body, contains('name="options"\r\n\r\nMemento'));
    expect(body, contains('name="options"\r\n\r\nInception'));
    expect(body, contains('name="tag"\r\n\r\npoll'));
    expect(body, isNot(contains('name="spoiler"')));
    expect(body, isNot(contains('name="scene"')));
  });

  test('postTopic sends scene, timecode and spoiler when set', () async {
    String? body;
    final client = MockClient((request) async {
      body = request.body;
      return http.Response(jsonEncode(_takeBody()), 201,
          headers: {'content-type': 'application/json'});
    });
    final repository = ApiReviewRepository(
      client: ApiClient(httpClient: client),
    );

    await repository.postTopic(
      filmId: 'tt1',
      body: 'Nothing moves.',
      tag: TakeTag.scene,
      scene: 'The interrogation room',
      timecode: '1h 12m',
      spoiler: true,
    );

    expect(body, contains('name="film_id"\r\n\r\ntt1'));
    expect(body, contains('name="scene"\r\n\r\nThe interrogation room'));
    expect(body, contains('name="timecode"\r\n\r\n1h 12m'));
    expect(body, contains('name="spoiler"\r\n\r\ntrue'));
    expect(body, contains('name="tag"\r\n\r\nscene'));
  });
}
