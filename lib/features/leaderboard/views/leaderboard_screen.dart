import 'package:flutter/material.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/avatar_frame.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/views/profile_screen.dart';
import '../data/leaderboard_models.dart';
import '../data/leaderboard_repository.dart';
import 'leaderboard_how_it_works_screen.dart';
import '../../../core/widgets/game_button.dart';

/// Top reviewers ranked by reactions on their reviews.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key, this.repository, this.onOpenUser});

  final LeaderboardRepository? repository;

  /// Called when a reviewer is tapped. Defaults to opening their profile.
  final ValueChanged<int>? onOpenUser;

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late final LeaderboardRepository _repository =
      widget.repository ?? LeaderboardRepository();
  LeaderboardPeriod _period = LeaderboardPeriod.week;
  LeaderboardBoard? _board;
  bool _loading = true;
  bool _failed = false;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final request = ++_request;
    try {
      final board = await _repository.fetch(_period);
      if (!mounted || request != _request) return;
      setState(() {
        _board = board;
        _loading = false;
        _failed = false;
      });
    } catch (_) {
      if (!mounted || request != _request) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  void _select(LeaderboardPeriod period) {
    if (period == _period) return;
    setState(() {
      _period = period;
      _loading = true;
      _failed = false;
    });
    _fetch();
  }

  void _openUser(int userId) {
    final onOpen = widget.onOpenUser;
    if (onOpen != null) {
      onOpen(userId);
      return;
    }
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => ProfileScreen(userId: userId)),
    );
  }

  void _openHowItWorks() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const LeaderboardHowItWorksScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
        child: ListView(
          padding: EdgeInsetsDirectional.fromSTEB(
            tokens.spaceLg,
            tokens.spaceMd,
            tokens.spaceLg,
            tokens.spaceXl,
          ),
          children: [
            _Header(
              title: l10n.leaderboardTitle,
              subtitle: l10n.leaderboardSubtitle,
              howLabel: l10n.leaderboardHowItWorks,
              onHow: _openHowItWorks,
            ),
            SizedBox(height: tokens.spaceMd),
            _PeriodSwitch(
              selected: _period,
              onChanged: _select,
              l10n: l10n,
            ),
            SizedBox(height: tokens.spaceLg),
            _buildBody(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    final board = _board;
    if (_failed && board == null) {
      return _ErrorState(message: l10n.leaderboardLoadFailed, onRetry: _fetch);
    }
    if (board == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (board.entries.isEmpty) {
      return _EmptyState(message: l10n.leaderboardEmpty);
    }

    final me = board.me;
    final myRowOutsideList = me != null &&
        me.rank != null &&
        !board.entries.any((entry) => entry.userId == me.userId);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _loading ? 0.5 : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Podium(
            key: ValueKey(board.period),
            entries: board.entries.take(3).toList(),
            l10n: l10n,
            onOpen: _openUser,
          ),
          SizedBox(height: context.tokens.spaceLg),
          for (final entry in board.entries) ...[
            _RankRow(
              entry: entry,
              isMe: me != null && entry.userId == me.userId,
              l10n: l10n,
              onTap: () => _openUser(entry.userId),
            ),
            SizedBox(height: context.tokens.spaceSm),
          ],
          if (myRowOutsideList) ...[
            SizedBox(height: context.tokens.spaceSm),
            _RankRow(
              entry: me,
              isMe: true,
              l10n: l10n,
              onTap: () => _openUser(me.userId),
            ),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.howLabel,
    required this.onHow,
  });

  final String title;
  final String subtitle;
  final String howLabel;
  final VoidCallback onHow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        GameButton(
          label: howLabel,
          style: GameButtonStyle.dark,
          onPressed: onHow,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ],
    );
  }
}

class _PeriodSwitch extends StatelessWidget {
  const _PeriodSwitch({
    required this.selected,
    required this.onChanged,
    required this.l10n,
  });

  final LeaderboardPeriod selected;
  final ValueChanged<LeaderboardPeriod> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final periods = [
      (LeaderboardPeriod.week, l10n.leaderboardPeriodWeek),
      (LeaderboardPeriod.month, l10n.leaderboardPeriodMonth),
      (LeaderboardPeriod.all, l10n.leaderboardPeriodAll),
    ];

    return Row(
      children: [
        for (final (period, label) in periods) ...[
          if (period != LeaderboardPeriod.week) SizedBox(width: tokens.spaceSm),
          Expanded(
            child: GameButton(
              label: label,
              pressed: period == selected,
              onPressed: () => onChanged(period),
              padding: const EdgeInsets.symmetric(vertical: 9),
            ),
          ),
        ],
      ],
    );
  }
}

/// Top three on a podium: 1st in the middle, taller and with a gold frame.
class _Podium extends StatelessWidget {
  const _Podium({
    super.key,
    required this.entries,
    required this.l10n,
    required this.onOpen,
  });

  final List<LeaderboardEntry> entries;
  final AppLocalizations l10n;
  final ValueChanged<int> onOpen;

  static const _slots = [
    // Display order: 2nd, 1st, 3rd. Frames come from each user's equipped frame.
    _Slot(index: 1, rank: 2, avatar: 74, step: 112, star: Color(0xFFC9D1DB)),
    _Slot(index: 0, rank: 1, avatar: 90, step: 150, star: Color(0xFFF5C23A)),
    _Slot(index: 2, rank: 3, avatar: 74, step: 84, star: Color(0xFFD08A56)),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return SizedBox(
      height: 330,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final slot in _slots)
            Expanded(
              child: slot.index < entries.length
                  ? _PodiumColumn(
                      entry: entries[slot.index],
                      slot: slot,
                      theme: theme,
                      l10n: l10n,
                      reduceMotion: reduceMotion,
                      onOpen: onOpen,
                    )
                  : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}

class _Slot {
  const _Slot({
    required this.index,
    required this.rank,
    required this.avatar,
    required this.step,
    required this.star,
  });

  final int index;
  final int rank;
  final double avatar;
  final double step;
  final Color star;
}

class _PodiumColumn extends StatelessWidget {
  const _PodiumColumn({
    required this.entry,
    required this.slot,
    required this.theme,
    required this.l10n,
    required this.reduceMotion,
    required this.onOpen,
  });

  final LeaderboardEntry entry;
  final _Slot slot;
  final ThemeData theme;
  final AppLocalizations l10n;
  final bool reduceMotion;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final duration =
        reduceMotion ? Duration.zero : const Duration(milliseconds: 900);

    return GestureDetector(
      onTap: () => onOpen(entry.userId),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              AvatarFrame(
                size: slot.avatar,
                frame: entry.equippedFrame,
                avatarUrl: entry.avatarUrl,
                initial: entry.username,
                backgroundColor: _colorFor(entry.userId),
                animate: !reduceMotion,
              ),
              PositionedDirectional(
                end: -4,
                top: -2,
                child: Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: slot.star,
                    border: Border.all(color: AppColors.background, width: 2),
                  ),
                  child: const Text(
                    '★',
                    style: TextStyle(fontSize: 12, color: Color(0xFF1A1A1A)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spaceMd),
          Text(
            entry.username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: tokens.spaceXs),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(tokens.radiusLg),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spaceSm,
                vertical: tokens.spaceXs,
              ),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: entry.reactions.toDouble()),
                duration: duration,
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: formatCount(value.round()),
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text:
                            ' ${l10n.leaderboardReactionsWord(entry.reactions)}',
                      ),
                    ],
                  ),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: tokens.spaceSm),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: slot.step),
            duration: duration,
            curve: Curves.easeOutBack,
            builder: (context, height, _) => Container(
              width: double.infinity,
              height: height,
              margin: EdgeInsets.symmetric(horizontal: tokens.spaceXs),
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(top: tokens.spaceXs),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1F2430), Color(0xFF16181D)],
                ),
                border: Border(
                  top: BorderSide(color: AppColors.accent, width: 8),
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
              ),
              child: Text(
                '${slot.rank}',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: AppColors.accent.withValues(alpha: 0.25),
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.entry,
    required this.isMe,
    required this.l10n,
    required this.onTap,
  });

  final LeaderboardEntry entry;
  final bool isMe;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final rank = entry.rank;
    final name = isMe
        ? '${entry.username} ${l10n.leaderboardYouSuffix}'
        : entry.username;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(tokens.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.spaceMd,
            vertical: tokens.spaceSm + tokens.spaceXs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(tokens.radiusLg),
            border:
                isMe ? Border.all(color: AppColors.accent, width: 1.5) : null,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  (rank ?? 0).toString().padLeft(2, '0'),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              // The row shows the reviewer's real equipped frame, still.
              SizedBox(
                width: 58,
                height: 58,
                child: Center(
                  child: AvatarFrame(
                    size: 32,
                    frame: entry.equippedFrame,
                    avatarUrl: entry.avatarUrl,
                    initial: entry.username,
                    backgroundColor: _colorFor(entry.userId),
                    animate: false,
                  ),
                ),
              ),
              SizedBox(width: tokens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      l10n.leaderboardReviewsCount(entry.reviews),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatCount(entry.reactions),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.accentGlow,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    l10n.leaderboardReactionsWord(entry.reactions),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        const SizedBox(height: 32),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 12),
        GameButton(
            label: l10n.leaderboardRetry,
            style: GameButtonStyle.blue,
            onPressed: onRetry),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
            ),
      ),
    );
  }
}

const _avatarPalette = [
  Color(0xFF2F6FDF),
  Color(0xFF1F9D8B),
  Color(0xFFC0486B),
  Color(0xFF8B4FD0),
  Color(0xFFC98A1B),
  Color(0xFF5B4FC4),
  Color(0xFF3A7CA5),
];

Color _colorFor(int userId) => _avatarPalette[userId % _avatarPalette.length];

/// 1234 -> "1,234" so large reaction totals stay readable in any locale.
String formatCount(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
