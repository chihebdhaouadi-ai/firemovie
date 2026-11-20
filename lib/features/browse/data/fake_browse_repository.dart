import '../../film_reviews/domain/take_tag.dart';
import '../../find/data/movie.dart';
import '../../home/data/home_models.dart';
import '../domain/browse_option.dart';
import '../domain/streaming_service.dart';
import 'browse_repository.dart';

/// In-memory [BrowseRepository] for tests and previews. Records the filters
/// it was asked for.
class FakeBrowseRepository implements BrowseRepository {
  FakeBrowseRepository({
    this.films = const [],
    this.services = const [],
    this.takes = const [],
    this.genres = const [],
    this.countries = const [],
    this.totalPages = 1,
    this.error,
  });

  final List<Movie> films;
  final List<StreamingService> services;
  final List<FeedItem> takes;
  final List<BrowseGenre> genres;
  final List<BrowseCountry> countries;
  final int totalPages;
  Object? error;

  final filmRequests = <({
    int page,
    int? year,
    int? serviceId,
    int? genreId,
    String? language,
    String? country,
  })>[];
  final takeRequests = <TakeTag?>[];

  @override
  Future<MovieSearchPage> fetchFilms({
    int page = 1,
    int? year,
    int? serviceId,
    int? genreId,
    String? language,
    String? country,
  }) async {
    filmRequests.add((
      page: page,
      year: year,
      serviceId: serviceId,
      genreId: genreId,
      language: language,
      country: country,
    ));
    if (error case final e?) throw e;
    return MovieSearchPage(
      page: page,
      totalPages: totalPages,
      totalResults: films.length * totalPages,
      results: films,
    );
  }

  @override
  Future<List<StreamingService>> fetchStreamingServices() async {
    if (error case final e?) throw e;
    return services;
  }

  @override
  Future<List<BrowseGenre>> fetchGenres() async {
    if (error case final e?) throw e;
    return genres;
  }

  @override
  Future<List<BrowseCountry>> fetchCountries() async {
    if (error case final e?) throw e;
    return countries;
  }

  @override
  Future<List<FeedItem>> fetchTopTakes({TakeTag? tag}) async {
    takeRequests.add(tag);
    if (error case final e?) throw e;
    return takes;
  }
}
