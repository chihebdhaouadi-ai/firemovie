import 'dart:convert';

import 'package:film_wise_mobile/features/home/data/home_models.dart';
import 'package:film_wise_mobile/features/home/data/home_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

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
}
