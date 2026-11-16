import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../data/debate_repository.dart';
import '../domain/debate.dart';
import '../../../core/widgets/game_button.dart';

enum _QuizPhase { answering, submitting, result, submitFailed }

class DebateQuizPage extends StatefulWidget {
  const DebateQuizPage({
    super.key,
    required this.debateId,
    required this.opponentName,
    required this.questions,
    required this.repository,
    this.questionDuration = const Duration(seconds: 15),
  });

  final String debateId;
  final String opponentName;
  final List<DebateQuestion> questions;
  final DebateRepository repository;
  final Duration questionDuration;

  @override
  State<DebateQuizPage> createState() => _DebateQuizPageState();
}

class _DebateQuizPageState extends State<DebateQuizPage> {
  final _answers = <String, int?>{};
  var _index = 0;
  var _secondsLeft = 0;
  var _phase = _QuizPhase.answering;
  DebateResult? _result;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _startQuestion();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  DebateQuestion get _question => widget.questions[_index];

  void _startQuestion() {
    _ticker?.cancel();
    _secondsLeft = widget.questionDuration.inSeconds;
    _ticker = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void _tick(Timer timer) {
    setState(() => _secondsLeft--);
    if (_secondsLeft <= 0) _choose(null);
  }

  void _choose(int? choice) {
    if (_phase != _QuizPhase.answering) return;
    _ticker?.cancel();
    _answers[_question.id] = choice;
    if (_index + 1 < widget.questions.length) {
      setState(() => _index++);
      _startQuestion();
    } else {
      _submit();
    }
  }

  Future<void> _submit() async {
    _ticker?.cancel();
    setState(() => _phase = _QuizPhase.submitting);
    try {
      final result = await widget.repository
          .submitAnswers(widget.debateId, Map.of(_answers));
      if (!mounted) return;
      setState(() {
        _result = result;
        _phase = _QuizPhase.result;
      });
    } on Exception {
      if (!mounted) return;
      setState(() => _phase = _QuizPhase.submitFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.debateVsTitle(widget.opponentName)),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.tokens.spaceMd * 2),
          child: switch (_phase) {
            _QuizPhase.answering => _questionView(context),
            _QuizPhase.submitting => const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            _QuizPhase.result => _resultView(context, _result!),
            _QuizPhase.submitFailed => _submitFailedView(context),
          },
        ),
      ),
    );
  }

  Widget _questionView(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(
          value: (_index + 1) / widget.questions.length,
          color: AppColors.accent,
          backgroundColor: AppColors.surfaceRaised,
        ),
        SizedBox(height: tokens.spaceMd),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.debateQuestionCounter(_index + 1, widget.questions.length),
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: AppColors.textMuted),
            ),
            Text(
              '$_secondsLeft',
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.spaceMd * 2),
        Text(_question.prompt, style: theme.textTheme.headlineSmall),
        SizedBox(height: tokens.spaceMd * 2),
        for (final (i, choice) in _question.choices.indexed) ...[
          GameButton(
            label: choice,
            style: GameButtonStyle.dark,
            onPressed: () => _choose(i),
          ),
          SizedBox(height: tokens.spaceSm),
        ],
      ],
    );
  }

  Widget _resultView(BuildContext context, DebateResult result) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final name = widget.opponentName;
    final outcomeText = switch (result.outcome) {
      DebateOutcome.won => l10n.debateResultWon,
      DebateOutcome.lost => l10n.debateResultLost(name),
      DebateOutcome.tied => l10n.debateResultTied,
    };
    final pointsText = switch (result.outcome) {
      DebateOutcome.won => l10n.debateSagePointsWon(result.sagePoints),
      DebateOutcome.lost => l10n.debateSagePointsLost(result.sagePoints, name),
      DebateOutcome.tied => null,
    };
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          outcomeText,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: result.outcome == DebateOutcome.won
                ? AppColors.accent
                : AppColors.textPrimary,
          ),
        ),
        SizedBox(height: tokens.spaceMd),
        Text(
          l10n.debateScoreLine(result.myScore, name, result.opponentScore),
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium
              ?.copyWith(color: AppColors.textSecondary),
        ),
        if (pointsText != null) ...[
          SizedBox(height: tokens.spaceMd),
          Text(
            pointsText,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.accentGlow,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        SizedBox(height: tokens.spaceMd * 2),
        GameButton(
          label: l10n.debateDone,
          style: GameButtonStyle.blue,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _submitFailedView(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.l10n.debateSubmitFailed,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: AppColors.error),
        ),
        SizedBox(height: tokens.spaceMd * 2),
        GameButton(
          label: context.l10n.debateRetry,
          style: GameButtonStyle.blue,
          onPressed: _submit,
        ),
      ],
    );
  }
}
