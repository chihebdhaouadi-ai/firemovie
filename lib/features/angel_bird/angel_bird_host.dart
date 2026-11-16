import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../core/l10n_context.dart';
import '../../core/session.dart';
import '../../core/theme/app_theme.dart';
import '../home/data/home_models.dart';
import '../home/data/home_repository.dart';
import '../overview/views/movie_overview_screen.dart';
import '../overview/views/widgets/overview_panel.dart';
import 'hold_gesture.dart';
import '../../core/widgets/game_button.dart';

const _holdDuration = Duration(seconds: 3);
const _birdSize = 120.0;
const _bubbleWidth = 360.0;

enum _Stage { hidden, question, loading, options, empty, failed }

class BirdOption {
  const BirdOption({required this.label, required this.page});

  final String label;
  final WidgetBuilder page;
}

class BirdRequest {
  const BirdRequest({
    required this.question,
    required this.pickPrompt,
    required this.emptyMessage,
    required this.failedMessage,
    required this.load,
  });

  final String question;
  final String pickPrompt;
  final String emptyMessage;
  final String failedMessage;
  final Future<List<BirdOption>> Function() load;
}

class AngelBirdHost extends StatefulWidget {
  const AngelBirdHost({
    super.key,
    required this.navigatorKey,
    required this.child,
    this.homeRepository,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;
  final HomeRepository? homeRepository;

  static void summon(BuildContext context, BirdRequest request) =>
      context.findAncestorStateOfType<_AngelBirdHostState>()?.present(request);

  @override
  State<AngelBirdHost> createState() => _AngelBirdHostState();
}

class _AngelBirdHostState extends State<AngelBirdHost>
    with SingleTickerProviderStateMixin {
  late final HomeRepository _repository =
      widget.homeRepository ?? ApiHomeRepository();
  late final AnimationController _flight = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  Timer? _holdTimer;
  Offset? _holdStart;
  _Stage _stage = _Stage.hidden;
  BirdRequest? _request;
  List<BirdOption> _options = const [];

  @override
  void dispose() {
    _holdTimer?.cancel();
    _flight.dispose();
    super.dispose();
  }

  bool _isEmptySpace(Offset position) {
    final navigator = widget.navigatorKey.currentContext;
    if (navigator == null) return false;
    final path = hitPathAt(context, position);
    if (isInHoldRegion(path)) return false;
    return !isTapTargetUnder(navigator, path);
  }

  void _handleDown(PointerDownEvent event) {
    _cancelHold();
    if (_stage != _Stage.hidden || !Session.isLoggedIn) return;
    if (!_isEmptySpace(event.position)) return;
    _holdStart = event.position;
    _holdTimer = Timer(_holdDuration, _summonTopFive);
  }

  void _handleMove(PointerMoveEvent event) {
    final start = _holdStart;
    if (start != null && (event.position - start).distance > kTouchSlop) {
      _cancelHold();
    }
  }

  void _cancelHold() {
    _holdTimer?.cancel();
    _holdTimer = null;
    _holdStart = null;
  }

  void _summonTopFive() {
    _holdTimer = null;
    _holdStart = null;
    present(_topFiveRequest());
  }

  BirdRequest _topFiveRequest() {
    final l10n = context.l10n;
    return BirdRequest(
      question: l10n.angelBirdQuestion,
      pickPrompt: l10n.angelBirdPickFilm,
      emptyMessage: l10n.angelBirdEmptyTop5,
      failedMessage: l10n.angelBirdLoadFailed,
      load: () async {
        final films = await _repository.fetch(HomeList.top5);
        return [
          for (final film in films)
            BirdOption(
              label: film.displayTitle,
              page: (_) => MovieOverviewScreen(film: film),
            ),
        ];
      },
    );
  }

  void present(BirdRequest request) {
    if (!mounted || _stage != _Stage.hidden || !Session.isLoggedIn) return;
    setState(() {
      _request = request;
      _stage = _Stage.question;
    });
    _flight.forward(from: 0);
  }

  Future<void> _ask() async {
    final request = _request;
    if (request == null) return;
    setState(() => _stage = _Stage.loading);
    try {
      final options = await request.load();
      if (!mounted || _stage != _Stage.loading) return;
      setState(() {
        _options = options;
        _stage = options.isEmpty ? _Stage.empty : _Stage.options;
      });
    } catch (_) {
      if (mounted && _stage == _Stage.loading) {
        setState(() => _stage = _Stage.failed);
      }
    }
  }

  Future<void> _flyAway() async {
    await _flight.reverse();
    if (mounted) setState(() => _stage = _Stage.hidden);
  }

  void _pick(BirdOption option) {
    _flight.value = 0;
    setState(() => _stage = _Stage.hidden);
    widget.navigatorKey.currentState?.push(
      MaterialPageRoute<void>(builder: option.page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slide = Tween<Offset>(begin: const Offset(0, -2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _flight, curve: Curves.easeOutCubic));
    final request = _request;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handleDown,
      onPointerMove: _handleMove,
      onPointerUp: (_) => _cancelHold(),
      onPointerCancel: (_) => _cancelHold(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (request != null && _stage != _Stage.hidden)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SlideTransition(
                    position: slide,
                    child: _BirdBubble(
                      stage: _stage,
                      request: request,
                      options: _options,
                      onYes: _ask,
                      onNotNow: _flyAway,
                      onPick: _pick,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BirdBubble extends StatelessWidget {
  const _BirdBubble({
    required this.stage,
    required this.request,
    required this.options,
    required this.onYes,
    required this.onNotNow,
    required this.onPick,
  });

  final _Stage stage;
  final BirdRequest request;
  final List<BirdOption> options;
  final VoidCallback onYes;
  final VoidCallback onNotNow;
  final ValueChanged<BirdOption> onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final body =
        theme.textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary);
    final notNow =
        TextButton(onPressed: onNotNow, child: Text(l10n.angelBirdNotNow));
    final gap = SizedBox(height: tokens.spaceMd);

    final Widget content = switch (stage) {
      _Stage.hidden => const SizedBox.shrink(),
      _Stage.question => _column([
          Text(request.question, style: body),
          gap,
          Wrap(
            spacing: tokens.spaceSm,
            runSpacing: tokens.spaceSm,
            children: [
              GameButton(label: l10n.angelBirdYes, style: GameButtonStyle.blue, onPressed: onYes),
              notNow,
            ],
          ),
        ]),
      _Stage.loading => const Center(child: CircularProgressIndicator()),
      _Stage.options => _column([
          Text(request.pickPrompt, style: body),
          SizedBox(height: tokens.spaceSm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: SingleChildScrollView(
              child: _column([
                for (final option in options)
                  Padding(
                    padding: EdgeInsets.only(bottom: tokens.spaceXs),
                    child: SizedBox(
                      width: double.infinity,
                      child: GameButton(
                        label: option.label,
                        style: GameButtonStyle.dark,
                        onPressed: () => onPick(option),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
          notNow,
        ]),
      _Stage.empty => _column([
          Text(request.emptyMessage, style: body),
          gap,
          notNow,
        ]),
      _Stage.failed => _column([
          Text(request.failedMessage, style: body),
          gap,
          Wrap(
            spacing: tokens.spaceSm,
            runSpacing: tokens.spaceSm,
            children: [
              GameButton(label: l10n.angelBirdRetry, style: GameButtonStyle.blue, onPressed: onYes),
              notNow,
            ],
          ),
        ]),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Lottie.asset(
            'assets/angel_bird.json',
            width: _birdSize,
            height: _birdSize,
            repeat: true,
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _bubbleWidth),
          child: Material(
            type: MaterialType.transparency,
            child: OverviewPanel(
              borderColor: AppColors.panelBorder,
              child: content,
            ),
          ),
        ),
      ],
    );
  }

  Widget _column(List<Widget> children) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
}
