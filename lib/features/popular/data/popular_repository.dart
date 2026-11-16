import '../../find/data/api_client.dart';
import 'popular_film.dart';

abstract class PopularRepository {
  Future<List<PopularFilm>> fetchThisWeek();
}

class ApiPopularRepository implements PopularRepository {
  ApiPopularRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<List<PopularFilm>> fetchThisWeek() async {
    final items = await _client.getList('/api/films/popular/');
    return items.map(PopularFilm.fromJson).toList(growable: false);
  }
}
