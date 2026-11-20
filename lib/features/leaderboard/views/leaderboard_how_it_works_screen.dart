import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/avatar_frame.dart';
import '../../profile/views/widgets/progress_catalog.dart';

/// Explains how the reviewer ranking, XP, badges, achievements and frames work.
class LeaderboardHowItWorksScreen extends StatelessWidget {
  const LeaderboardHowItWorksScreen({super.key});

  // Mirrors the XP values the server awards (see takes/reputation.py).
  static const _xpReview = 20;
  static const _xpComment = 5;
  static const _xpReaction = 2;

  // Thresholds that unlock each item; they must match the server rules.
  static const _badgeTargets = {
    'well_argued': 10,
    'changed_my_mind': 10,
    'disagree_but_fair': 10,
    'top_critic': 1,
    'first_take': 1,
  };
  static const _achievementTargets = {
    'film_critic': 10,
    'debater': 50,
    'local_cinema': 20,
  };
  static const _frameTargets = {
    'bronze': 0,
    'explorer': 10,
    'debater': 50,
    'gold': 15,
    'legend': 30,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.leaderboardHowItWorks),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              tokens.spaceLg,
              tokens.spaceSm,
              tokens.spaceLg,
              tokens.spaceXl,
            ),
            children: [
              _Title(text: l10n.howRankingTitle),
              _Step(
                  number: 1,
                  title: l10n.howStep1Title,
                  body: l10n.howStep1Body),
              _Step(
                  number: 2,
                  title: l10n.howStep2Title,
                  body: l10n.howStep2Body),
              _Step(
                  number: 3,
                  title: l10n.howStep3Title,
                  body: l10n.howStep3Body),
              SizedBox(height: tokens.spaceMd),
              Wrap(
                spacing: tokens.spaceSm,
                runSpacing: tokens.spaceSm,
                children: [
                  _ReactionChip(label: l10n.badgeWellArguedTitle),
                  _ReactionChip(label: l10n.badgeChangedMindTitle),
                  _ReactionChip(label: l10n.badgeDisagreeTitle),
                ],
              ),
              SizedBox(height: tokens.spaceMd),
              _Note(text: l10n.howNoteReset),
              _Note(text: l10n.howNoteOncePerReview),
              _Note(text: l10n.howNoteTie),
              _Note(text: l10n.howNotePodium),
              _Title(text: l10n.howLevelsTitle),
              _Card(
                children: [
                  _XpRow(
                      label: l10n.howXpReview,
                      value: l10n.howXpValue(_xpReview)),
                  _XpRow(
                      label: l10n.howXpComment,
                      value: l10n.howXpValue(_xpComment)),
                  _XpRow(
                      label: l10n.howXpReaction,
                      value: l10n.howXpValue(_xpReaction)),
                ],
              ),
              SizedBox(height: tokens.spaceSm),
              Text(
                l10n.howLevelFoot,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              _Title(text: l10n.profileBadgesTitle),
              for (final entry in _badgeTargets.entries)
                _IconRow(
                  asset: badgeInfo(l10n, entry.key, entry.value).asset!,
                  title: badgeInfo(l10n, entry.key, entry.value).title,
                  body: badgeInfo(l10n, entry.key, entry.value).description,
                ),
              _Title(text: l10n.profileAchievementsTitle),
              for (final entry in _achievementTargets.entries)
                _IconRow(
                  asset: achievementInfo(l10n, entry.key, entry.value).asset!,
                  title: achievementInfo(l10n, entry.key, entry.value).title,
                  body:
                      achievementInfo(l10n, entry.key, entry.value).description,
                ),
              _Title(text: l10n.profileFramesTitle),
              for (final entry in _frameTargets.entries)
                _FrameRow(
                  frameKey: entry.key,
                  title: frameInfo(l10n, entry.key, entry.value).title,
                  body: frameInfo(l10n, entry.key, entry.value).description,
                  initial: 'M',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsets.only(top: tokens.spaceXl, bottom: tokens.spaceMd),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: tokens.spaceMd),
        child: Column(children: children),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.title, required this.body});

  final int number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spaceSm),
      child: Container(
        padding: EdgeInsets.all(tokens.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(tokens.radiusLg),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.accent,
              child: Text(
                '$number',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: tokens.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReactionChip extends StatelessWidget {
  const _ReactionChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.tabUnselected,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spaceSm + tokens.spaceXs,
          vertical: tokens.spaceXs + 2,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spaceXs),
      child: Text(
        '•  $text',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
              height: 1.5,
            ),
      ),
    );
  }
}

class _XpRow extends StatelessWidget {
  const _XpRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.spaceSm + 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.accentGlow,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconRow extends StatelessWidget {
  const _IconRow(
      {required this.asset, required this.title, required this.body});

  final String asset;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spaceSm),
      child: Container(
        padding: EdgeInsets.all(tokens.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(tokens.radiusLg),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: Lottie.asset(
                'assets/lottie/badge_$asset.json',
                repeat: false,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: tokens.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FrameRow extends StatelessWidget {
  const _FrameRow({
    required this.frameKey,
    required this.title,
    required this.body,
    required this.initial,
  });

  final String frameKey;
  final String title;
  final String body;
  final String initial;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spaceSm),
      child: Container(
        padding: EdgeInsets.all(tokens.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(tokens.radiusLg),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Center(
                child: AvatarFrame(
                  size: 44,
                  frame: frameKey,
                  initial: initial,
                  backgroundColor: AppColors.surfaceRaised,
                ),
              ),
            ),
            SizedBox(width: tokens.spaceSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
