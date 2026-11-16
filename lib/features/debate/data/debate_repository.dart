import '../domain/debate.dart';

abstract interface class DebateRepository {
  Future<DebateInvite> invite(int opponentUserId);

  Future<DebateStatus> fetchStatus(String debateId);

  Future<List<DebateQuestion>> fetchQuestions(String debateId);

  /// Maps question id to the chosen choice index, or null when time ran out.
  Future<DebateResult> submitAnswers(
    String debateId,
    Map<String, int?> answers,
  );
}
