enum DebateStatus { pending, accepted, declined }

final class DebateInvite {
  const DebateInvite({required this.id});

  final String id;
}

final class DebateQuestion {
  const DebateQuestion({
    required this.id,
    required this.prompt,
    required this.choices,
  });

  final String id;
  final String prompt;
  final List<String> choices;
}

enum DebateOutcome { won, lost, tied }

final class DebateResult {
  const DebateResult({
    required this.myScore,
    required this.opponentScore,
    required this.outcome,
    required this.sagePoints,
  });

  final int myScore;
  final int opponentScore;
  final DebateOutcome outcome;
  final int sagePoints;
}
