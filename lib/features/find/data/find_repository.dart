import 'api_client.dart';
import 'movie.dart';
import 'movie_parser.dart';

/// Search + detail through the backend TMDB proxy.
class FindRepository {
  FindRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<MovieSearchPage> search(String query, {int page = 1}) async {
    final json = await _client.getJson(
      '/api/films/search',
      query: {'q': query, 'page': '$page'},
    );
    return MovieParser.searchPage(json);
  }

  Future<Movie> fetchDetail(String filmId) async {
    final json = await _client.getJson('/api/films/$filmId/');
    return MovieParser.detail(json);
  }
}
