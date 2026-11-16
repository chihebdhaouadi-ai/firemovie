import 'package:film_wise_mobile/features/popular/data/popular_film.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a popular film from the API', () {
    final film = PopularFilm.fromJson({
      'film_id': 'tt0111161',
      'title': 'The Shawshank Redemption',
      'year': 1994,
      'poster_url': 'https://example.com/p.jpg',
      'adds': 12,
    });

    expect(film.filmId, 'tt0111161');
    expect(film.title, 'The Shawshank Redemption');
    expect(film.year, 1994);
    expect(film.posterUrl, 'https://example.com/p.jpg');
    expect(film.adds, 12);
  });

  test('accepts missing title and poster', () {
    final film = PopularFilm.fromJson({
      'film_id': 'tt0000001',
      'title': null,
      'year': null,
      'poster_url': null,
      'adds': 1,
    });

    expect(film.title, '');
    expect(film.posterUrl, isNull);
  });
}
