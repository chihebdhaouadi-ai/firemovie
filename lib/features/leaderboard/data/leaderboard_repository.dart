import '../../find/data/api_client.dart';
import 'leaderboard_models.dart';

class LeaderboardRepository {
  LeaderboardRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<LeaderboardBoard> fetch(LeaderboardPeriod period) async {
    final json = await _client.getJson(
      '/api/takes/leaderboard/',
      query: {'period': period.name},
    );
    final entries = [
      for (final item in json['entries'] as List<dynamic>? ?? const [])
        LeaderboardEntry.fromJson(item as Map<String, dynamic>),
    ];
    final me = json['me'];
    return LeaderboardBoard(
      period: period,
      entries: entries,
      me: me is Map<String, dynamic> ? LeaderboardEntry.fromJson(me) : null,
    );
  }
}
