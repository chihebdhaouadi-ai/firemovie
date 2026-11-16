import '../../find/data/api_client.dart';
import 'upcoming_film.dart';

abstract class UpcomingRepository {
  Future<List<UpcomingFilm>> fetchUpcoming();
}

class ApiUpcomingRepository implements UpcomingRepository {
  ApiUpcomingRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<List<UpcomingFilm>> fetchUpcoming() async {
    final items = await _client.getList('/api/upcoming/');
    return items.map(UpcomingFilm.fromJson).toList(growable: false);
  }
}
