import 'package:film_wise_mobile/features/find/data/movie.dart';
import 'package:film_wise_mobile/features/find/data/movie_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MovieParser.searchPage', () {
    test('parses a page of results including in_lists badges', () {
      final json = {
        'page': 1,
        'total_pages': 3,
        'total_results': 50,
        'results': [
          {
            'film_id': '278',
            'title': 'The Shawshank Redemption',
            'year': 1994,
            'poster_url': 'https://image.tmdb.org/t/p/w342/p.jpg',
            'in_lists': ['watched'],
          },
        ],
      };
      final page = MovieParser.searchPage(json);
      expect(page.page, 1);
      expect(page.totalPages, 3);
      expect(page.totalResults, 50);
      expect(page.hasMore, isTrue);
      expect(page.results, hasLength(1));
      final movie = page.results.first;
      expect(movie.id, '278');
      expect(movie.title, 'The Shawshank Redemption');
      expect(movie.year, 1994);
      expect(movie.posterUrl, 'https://image.tmdb.org/t/p/w342/p.jpg');
      expect(movie.inLists, ['watched']);
      expect(movie.isWatched, isTrue);
      expect(movie.isTop5, isFalse);
    });

    test('skips rows without an id', () {
      final page = MovieParser.searchPage({
        'results': [
          {'title': 'No id'},
          {'film_id': '1', 'title': 'Has id'},
        ],
      });
      expect(page.results, hasLength(1));
      expect(page.results.first.id, '1');
    });
  });

  group('MovieParser.detail', () {
    test('parses the enriched detail payload', () {
      final json = {
        'film_id': '278',
        'tmdb_id': '278',
        'imdb_id': 'tt0111161',
        'title': 'The Shawshank Redemption',
        'year': 1994,
        'overview': 'Hope.',
        'runtime': 142,
        'genres': ['Drama'],
        'vote_average': 8.7,
        'poster_url': 'https://image.tmdb.org/t/p/w342/p.jpg',
        'backdrop_url': 'https://image.tmdb.org/t/p/w342/b.jpg',
        'watch_providers': {
          'link': 'https://www.justwatch.com/us/movie/x',
          'available': [
            {
              'name': 'Netflix',
              'logo_url': 'https://x/n.png',
              'url': 'https://n/x'
            },
          ],
        },
        'in_lists': ['top_5'],
      };
      final movie = MovieParser.detail(json);
      expect(movie.id, '278');
      expect(movie.runtime, 142);
      expect(movie.genres, ['Drama']);
      expect(movie.voteAverage, 8.7);
      expect(movie.watchProviders, isNotNull);
      expect(movie.watchProviders!.available.single.name, 'Netflix');
      expect(movie.watchProviders!.available.single.url, 'https://n/x');
      expect(movie.isTop5, isTrue);
    });

    test('keeps only https logo and link urls for providers', () {
      final movie = MovieParser.detail({
        'film_id': '278',
        'watch_providers': {
          'available': [
            {'name': 'Max', 'logo_url': 'http://x/m.png', 'url': 'http://m/x'},
            {
              'name': 'Hulu',
              'logo_url': 'https://x/h.png',
              'url': 'https://h/x'
            },
          ],
        },
      });
      final providers = movie.watchProviders!.available;
      expect(providers[0].logoUrl, isNull);
      expect(providers[0].url, isNull);
      expect(providers[1].logoUrl, 'https://x/h.png');
      expect(providers[1].url, 'https://h/x');
    });

    test('parses trailer, cast, crew and provider offers', () {
      final movie = MovieParser.detail({
        'film_id': 'tt1345836',
        'trailer_url': 'https://www.youtube.com/watch?v=x',
        'trailer_youtube_id': 'tc-TXxekXWo',
        'cast': [
          {'name': 'Christian Bale', 'role': 'Bruce Wayne'},
          {'name': '', 'role': 'Nobody'},
        ],
        'crew': [
          {'name': 'Christopher Nolan', 'job': 'Director, Screenplay'},
        ],
        'watch_providers': {
          'available': [
            {'name': 'HBO Max', 'type': 'sub', 'url': 'https://max/x'},
            {
              'name': 'Amazon',
              'type': 'rent',
              'price': 3.99,
              'url': 'https://a/x'
            },
            {'name': 'Odd', 'type': 'weird', 'url': 'https://o/x'},
          ],
        },
      });
      expect(movie.trailerUrl, 'https://www.youtube.com/watch?v=x');
      expect(movie.trailerYoutubeId, 'tc-TXxekXWo');
      expect(movie.cast,
          const [CastMember(name: 'Christian Bale', role: 'Bruce Wayne')]);
      expect(movie.crew.single.job, 'Director, Screenplay');
      final providers = movie.watchProviders!.available;
      expect(providers.map((p) => p.offer),
          [ProviderOffer.subscription, ProviderOffer.rent, null]);
      expect(providers[1].price, 3.99);
    });

    test('ignores a non-https trailer link', () {
      final movie = MovieParser.detail({
        'film_id': 'tt1',
        'trailer_url': 'http://insecure/x',
        'trailer_youtube_id': 'not a video id',
      });
      expect(movie.trailerUrl, isNull);
      expect(movie.trailerYoutubeId, isNull);
      expect(movie.cast, isEmpty);
    });

    test('defaults to the numeric id in the search payload', () {
      final movie = MovieParser.searchResult({
        'film_id': null,
        'tmdb_id': '11',
        'title': 'The Matrix',
        'year': '1999',
      });
      expect(movie.id, '11');
      expect(movie.year, 1999);
    });
  });
}
