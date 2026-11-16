import 'package:film_wise_mobile/features/debate/data/debate_repository.dart';
import 'package:film_wise_mobile/features/debate/domain/debate.dart';

const sampleQuestions = [
  DebateQuestion(
    id: 'q1',
    prompt: 'Who directed the film?',
    choices: ['Q1 A', 'Q1 B', 'Q1 C'],
  ),
  DebateQuestion(
    id: 'q2',
    prompt: 'Where was it shot?',
    choices: ['Q2 A', 'Q2 B', 'Q2 C'],
  ),
  DebateQuestion(
    id: 'q3',
    prompt: 'What year did it release?',
    choices: ['Q3 A', 'Q3 B', 'Q3 C'],
  ),
  DebateQuestion(
    id: 'q4',
    prompt: 'Who composed the score?',
    choices: ['Q4 A', 'Q4 B', 'Q4 C'],
  ),
  DebateQuestion(
    id: 'q5',
    prompt: 'Which studio produced it?',
    choices: ['Q5 A', 'Q5 B', 'Q5 C'],
  ),
];

class FakeDebateRepository implements DebateRepository {
  FakeDebateRepository({
    this.statuses = const [DebateStatus.accepted],
    this.questions = sampleQuestions,
    this.result = const DebateResult(
      myScore: 3,
      opponentScore: 1,
      outcome: DebateOutcome.won,
      sagePoints: 40,
    ),
    this.inviteError,
  });

  final List<DebateStatus> statuses;
  final List<DebateQuestion> questions;
  final DebateResult result;
  final Exception? inviteError;

  final invitedUserIds = <int>[];
  final submissions = <Map<String, int?>>[];
  int statusRequests = 0;
  int questionRequests = 0;

  @override
  Future<DebateInvite> invite(int opponentUserId) async {
    invitedUserIds.add(opponentUserId);
    final error = inviteError;
    if (error != null) throw error;
    return const DebateInvite(id: 'debate-1');
  }

  @override
  Future<DebateStatus> fetchStatus(String debateId) async {
    final index =
        statusRequests < statuses.length ? statusRequests : statuses.length - 1;
    statusRequests++;
    return statuses[index];
  }

  @override
  Future<List<DebateQuestion>> fetchQuestions(String debateId) async {
    questionRequests++;
    return questions;
  }

  @override
  Future<DebateResult> submitAnswers(
    String debateId,
    Map<String, int?> answers,
  ) async {
    submissions.add(Map.of(answers));
    return result;
  }
}
