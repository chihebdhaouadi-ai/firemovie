import '../../find/data/api_client.dart';
import '../../find/data/movie.dart';
import '../domain/debate.dart';
import 'debate_repository.dart';

class ApiDebateRepository implements DebateRepository {
  ApiDebateRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<DebateInvite> invite(int opponentUserId) async {
    final json = await _client.postJson(
      '/api/debates/invites/',
      body: {'opponent_id': opponentUserId},
    );
    return DebateInvite(id: _string(json, 'id'));
  }

  @override
  Future<DebateStatus> fetchStatus(String debateId) async {
    final json = await _client.getJson('/api/debates/$debateId/');
    return switch (_string(json, 'status')) {
      'pending' => DebateStatus.pending,
      'accepted' => DebateStatus.accepted,
      'declined' => DebateStatus.declined,
      _ => throw _badResponse(),
    };
  }

  @override
  Future<List<DebateQuestion>> fetchQuestions(String debateId) async {
    final list = await _client.getList('/api/debates/$debateId/questions/');
    return [
      for (final item in list)
        DebateQuestion(
          id: _string(item, 'id'),
          prompt: _string(item, 'prompt'),
          choices: [for (final c in _list(item, 'choices')) c as String],
        ),
    ];
  }

  @override
  Future<DebateResult> submitAnswers(
    String debateId,
    Map<String, int?> answers,
  ) async {
    final json = await _client.postJson(
      '/api/debates/$debateId/answers/',
      body: {
        'answers': [
          for (final entry in answers.entries)
            {'question_id': entry.key, 'choice': entry.value},
        ],
      },
    );
    return DebateResult(
      myScore: _int(json, 'my_score'),
      opponentScore: _int(json, 'opponent_score'),
      outcome: switch (_string(json, 'outcome')) {
        'won' => DebateOutcome.won,
        'lost' => DebateOutcome.lost,
        'tied' => DebateOutcome.tied,
        _ => throw _badResponse(),
      },
      sagePoints: _int(json, 'sage_points'),
    );
  }

  static String _string(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String) return value;
    throw _badResponse();
  }

  static int _int(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) return value;
    throw _badResponse();
  }

  static List<dynamic> _list(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is List) return value;
    throw _badResponse();
  }

  static ServerFailure _badResponse() =>
      ServerFailure('bad_response', 'Unexpected response from server.');
}
