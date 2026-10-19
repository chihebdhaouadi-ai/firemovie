import 'dart:convert';

import 'package:film_wise_mobile/core/session.dart';
import 'package:film_wise_mobile/features/find/data/api_client.dart';
import 'package:film_wise_mobile/features/find/data/find_repository.dart';
import 'package:film_wise_mobile/features/find/data/movie.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('FindRepository', () {
    test('search sends the Authorization header when logged in', () async {
      final previous = Session.token;
      Session.token = 'secret-token';
      try {
        late http.Request captured;
        final client = MockClient((request) async {
          captured = request;
          return http.Response(
            jsonEncode({
              'page': 1,
              'total_pages': 1,
              'total_results': 1,
              'results': [
                {'film_id': '278', 'title': 'The Shawshank Redemption'},
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final repo = FindRepository(client: ApiClient(httpClient: client));
        await repo.search('shaw');

        expect(captured.headers['authorization'], 'Token secret-token');
      } finally {
        Session.token = previous;
      }
    });

    test('search hits /api/films/search with query and page', () async {
      late Uri captured;
      final client = MockClient((request) async {
        captured = request.url;
        return http.Response(
          jsonEncode({
            'page': 2,
            'total_pages': 5,
            'total_results': 100,
            'results': [
              {
                'film_id': '278',
                'title': 'The Shawshank Redemption',
                'year': 1994
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = FindRepository(client: ApiClient(httpClient: client));
      final page = await repo.search('shaw', page: 2);

      expect(captured.path, '/api/films/search');
      expect(captured.queryParameters['q'], 'shaw');
      expect(captured.queryParameters['page'], '2');
      expect(page.page, 2);
      expect(page.results.first.title, 'The Shawshank Redemption');
    });

    test('search maps an HTTP 400 error body to a ServerFailure', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({'detail': 'Too short.', 'code': 'query_too_short'}),
          400,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = FindRepository(client: ApiClient(httpClient: client));
      await expectLater(
        repo.search('a'),
        throwsA(isA<ServerFailure>()
            .having((f) => f.code, 'code', 'query_too_short')
            .having((f) => f.message, 'message', 'Too short.')),
      );
    });

    test('search maps a 401 to an AuthFailure', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode(
              {'detail': 'Not authenticated.', 'code': 'not_authenticated'}),
          401,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = FindRepository(client: ApiClient(httpClient: client));
      await expectLater(
        repo.search('matrix'),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('search maps a 5xx to a ServerFailure', () async {
      final client = MockClient((request) async {
        return http.Response('boom', 500);
      });
      final repo = FindRepository(client: ApiClient(httpClient: client));
      await expectLater(
        repo.search('matrix'),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('detail hits /api/films/{id}/', () async {
      late Uri captured;
      final client = MockClient((request) async {
        captured = request.url;
        return http.Response(
          jsonEncode({
            'film_id': '278',
            'title': 'The Shawshank Redemption',
            'year': 1994,
            'genres': ['Drama'],
            'watch_providers': {
              'link': null,
              'flatrate': [],
              'rent': [],
              'buy': []
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = FindRepository(client: ApiClient(httpClient: client));
      final movie = await repo.fetchDetail('278');
      expect(captured.path, '/api/films/278/');
      expect(movie.id, '278');
      expect(movie.genres, ['Drama']);
    });
  });
}
