import '../../film_reviews/data/review_parser.dart';
import '../../film_reviews/domain/take_tag.dart';
import '../../find/data/api_client.dart';
import '../../find/data/movie.dart';
import '../../find/data/movie_parser.dart';
import '../../home/data/home_models.dart';
import '../domain/browse_option.dart';
import '../domain/streaming_service.dart';

/// Lists behind the search page's browse menu.
abstract interface class BrowseRepository {
  /// One page of films, most popular first. Optional filters: release [year],
  /// streaming [serviceId], [genreId], original [language] (ISO 639-1) and
  /// [country] where the film is streaming (ISO 3166-1).
  Future<MovieSearchPage> fetchFilms({
    int page = 1,
    int? year,
    int? serviceId,
    int? genreId,
    String? language,
    String? country,
  });

  /// Film genres, alphabetical.
  Future<List<BrowseGenre>> fetchGenres();

  /// Countries films can be browsed by (where they are streaming).
  Future<List<BrowseCountry>> fetchCountries();

  /// Streaming services the user can browse by, most prominent first.
  Future<List<StreamingService>> fetchStreamingServices();

  /// The top 100 takes of all time, or only those of [tag].
  Future<List<FeedItem>> fetchTopTakes({TakeTag? tag});
}

class ApiBrowseRepository implements BrowseRepository {
  ApiBrowseRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<MovieSearchPage> fetchFilms({
    int page = 1,
    int? year,
    int? serviceId,
    int? genreId,
    String? language,
    String? country,
  }) async {
    final json = await _client.getJson(
      '/api/films/browse/',
      query: {
        'page': '$page',
        if (year != null) 'year': '$year',
        if (serviceId != null) 'provider': '$serviceId',
        if (genreId != null) 'genre': '$genreId',
        if (language != null) 'language': language,
        if (country != null) 'country': country,
      },
    );
    return MovieParser.searchPage(json);
  }

  @override
  Future<List<BrowseGenre>> fetchGenres() async {
    final rows = await _client.getList('/api/films/genres/');
    return rows
        .map(BrowseGenre.fromJson)
        .where((genre) => genre.id > 0 && genre.name.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Future<List<BrowseCountry>> fetchCountries() async {
    final rows = await _client.getList('/api/films/countries/');
    return rows
        .map(BrowseCountry.fromJson)
        .where((country) => country.code.length == 2 && country.name.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Future<List<StreamingService>> fetchStreamingServices() async {
    final rows = await _client.getList('/api/films/providers/');
    return rows
        .map(StreamingService.fromJson)
        .where((service) => service.id > 0 && service.name.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Future<List<FeedItem>> fetchTopTakes({TakeTag? tag}) async {
    return ReviewParser.exploreItems(
      await _client.getList(
        '/api/takes/top/',
        query: {if (tag != null) 'tag': tag.apiValue},
      ),
    );
  }
}
