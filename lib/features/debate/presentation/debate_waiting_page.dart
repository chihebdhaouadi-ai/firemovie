import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../data/api_debate_repository.dart';
import '../data/debate_repository.dart';
import '../domain/debate.dart';
import 'debate_quiz_page.dart';
import '../../../core/widgets/game_button.dart';

enum _Phase { inviting, waiting, declined, failed }

class DebateWaitingPage extends StatefulWidget {
  const DebateWaitingPage({
    super.key,
    required this.opponentId,
    required this.opponentName,
    this.repository,
    this.pollInterval = const Duration(seconds: 3),
  });

  final int opponentId;
  final String opponentName;
  final DebateRepository? repository;
  final Duration pollInterval;

  @override
  State<DebateWaitingPage> createState() => _DebateWaitingPageState();
}

class _DebateWaitingPageState extends State<DebateWaitingPage> {
  late final DebateRepository _repository;
  var _started = false;
  var _phase = _Phase.inviting;
  var _polling = false;
  var _failure = '';
  String? _debateId;
  VoidCallback? _retry;
  Timer? _pollTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _repository = widget.repository ?? _providedRepository();
    _invite();
  }

  DebateRepository _providedRepository() {
    try {
      return RepositoryProvider.of<DebateRepository>(context);
    } on FlutterError {
      return ApiDebateRepository();
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _invite() async {
    final l10n = context.l10n;
    try {
      final DebateInvite invite = await _repository.invite(widget.opponentId);
      if (!mounted) return;
      _debateId = invite.id;
      setState(() => _phase = _Phase.waiting);
      _pollTimer = Timer.periodic(widget.pollInterval, (_) => _poll());
    } on Exception {
      if (mounted) _fail(l10n.debateInviteFailed, _invite);
    }
  }

  Future<void> _poll() async {
    final id = _debateId;
    if (_polling || id == null) return;
    _polling = true;
    try {
      final status = await _repository.fetchStatus(id);
      if (!mounted) return;
      switch (status) {
        case DebateStatus.pending:
          return;
        case DebateStatus.declined:
          _pollTimer?.cancel();
          setState(() => _phase = _Phase.declined);
        case DebateStatus.accepted:
          _pollTimer?.cancel();
          await _loadQuestions();
      }
    } on Exception {
      // A dropped poll keeps the invite open; the next tick checks again.
    } finally {
      _polling = false;
    }
  }

  Future<void> _loadQuestions() async {
    final id = _debateId;
    if (id == null) return;
    final l10n = context.l10n;
    try {
      final questions = await _repository.fetchQuestions(id);
      if (!mounted) return;
      if (questions.isEmpty) {
        _fail(l10n.debateLoadFailed, _loadQuestions);
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => DebateQuizPage(
            debateId: id,
            opponentName: widget.opponentName,
            questions: questions,
            repository: _repository,
          ),
        ),
      );
    } on Exception {
      if (mounted) _fail(l10n.debateLoadFailed, _loadQuestions);
    }
  }

  void _fail(String message, VoidCallback retry) {
    _pollTimer?.cancel();
    setState(() {
      _phase = _Phase.failed;
      _failure = message;
      _retry = retry;
    });
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
          child: Center(child: _content(context)),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final name = widget.opponentName;
    final body =
        theme.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary);
    final cancel = TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text(l10n.debateCancel),
    );

    return switch (_phase) {
      _Phase.inviting || _Phase.waiting => _column([
          CircularProgressIndicator(color: AppColors.accent),
          SizedBox(height: tokens.spaceMd * 2),
          Text(
            l10n.debateWaitingTitle(name),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          SizedBox(height: tokens.spaceSm),
          Text(
            l10n.debateWaitingBody(name),
            textAlign: TextAlign.center,
            style: body,
          ),
          SizedBox(height: tokens.spaceMd * 2),
          cancel,
        ]),
      _Phase.declined => _column([
          Text(
            l10n.debateDeclined(name),
            textAlign: TextAlign.center,
            style: body,
          ),
          SizedBox(height: tokens.spaceMd * 2),
          GameButton(
            label: l10n.debateDone,
            style: GameButtonStyle.blue,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ]),
      _Phase.failed => _column([
          Text(_failure, textAlign: TextAlign.center, style: body),
          SizedBox(height: tokens.spaceMd * 2),
          GameButton(
              label: l10n.debateRetry,
              style: GameButtonStyle.blue,
              onPressed: _retry),
          cancel,
        ]),
    };
  }

  Widget _column(List<Widget> children) => Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
}
