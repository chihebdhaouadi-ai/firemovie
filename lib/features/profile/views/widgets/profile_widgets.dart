import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/avatar_frame.dart';
import '../../data/profile_models.dart';
import 'profile_game_kit.dart';
import 'progress_catalog.dart';
import '../../../../core/widgets/game_button.dart';

/// Stat accents, matching the SAGE game palette.
Color get _reviewsColor =>
    themed(const Color(0xFF6AA8FF), const Color(0xFF1C5FB0));
Color get _reactionsColor =>
    themed(const Color(0xFFFFD75E), const Color(0xFF8A5A00));
Color get _commentsColor =>
    themed(const Color(0xFFFF8A4A), const Color(0xFFB0481A));

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(top: tokens.spaceXl, bottom: tokens.spaceMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.accentGlow,
              ),
            ),
        ],
      ),
    );
  }
}

/// Three raised stat cards: reviews, reactions received, comments written.
class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({super.key, required this.progress});

  final ProfileProgress progress;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: GameStatCard(
            label: l10n.profileStatReviews,
            value: _compact(progress.reviews),
            color: _reviewsColor,
          ),
        ),
        SizedBox(width: tokens.spaceSm),
        Expanded(
          child: GameStatCard(
            label: l10n.profileStatReactions,
            value: _compact(progress.reactions),
            color: _reactionsColor,
          ),
        ),
        SizedBox(width: tokens.spaceSm),
        Expanded(
          child: GameStatCard(
            label: l10n.profileStatComments,
            value: _compact(progress.comments),
            color: _commentsColor,
          ),
        ),
      ],
    );
  }

  static String _compact(int value) {
    if (value >= 1000) {
      final thousands = value / 1000;
      return '${thousands.toStringAsFixed(thousands >= 10 ? 0 : 1)}K';
    }
    return '$value';
  }
}

/// Horizontal row of badge medallions; locked badges are dimmed.
class ProfileBadgesSection extends StatelessWidget {
  const ProfileBadgesSection({super.key, required this.badges});

  final List<ProgressItem> badges;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: l10n.profileBadgesTitle),
        SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: badges.length,
            separatorBuilder: (_, __) => SizedBox(width: tokens.spaceLg),
            itemBuilder: (context, index) {
              final badge = badges[index];
              final info = badgeInfo(l10n, badge.key, badge.target);
              return Tooltip(
                message: info.description,
                triggerMode: TooltipTriggerMode.longPress,
                child: SizedBox(
                  width: 74,
                  child: Column(
                    children: [
                      GameBadge(
                        locked: !badge.unlocked,
                        owned: badge.unlocked,
                        child: info.asset == null
                            ? const SizedBox.shrink()
                            : Lottie.asset(
                                'assets/lottie/badge_${info.asset}.json',
                                repeat: false,
                                fit: BoxFit.contain,
                              ),
                      ),
                      SizedBox(height: tokens.spaceXs),
                      Text(
                        info.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: badge.unlocked
                              ? AppColors.textSecondary
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Frame picker. Unlocked frames can be equipped; locked ones show why.
class ProfileFramesSection extends StatelessWidget {
  const ProfileFramesSection({
    super.key,
    required this.frames,
    required this.equipped,
    required this.initial,
    required this.onSelect,
  });

  final List<ProgressItem> frames;
  final String equipped;
  final String initial;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          title: l10n.profileFramesTitle,
          trailing: l10n.frameTapToEquip,
        ),
        SizedBox(
          height: 184,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: frames.length,
            separatorBuilder: (_, __) => SizedBox(width: tokens.spaceSm),
            itemBuilder: (context, index) {
              final frame = frames[index];
              final info = frameInfo(l10n, frame.key, frame.target);
              final isEquipped = frame.key == equipped;
              return _FrameTile(
                frameKey: frame.key,
                title: info.title,
                note: frame.unlocked
                    ? (isEquipped ? l10n.frameEquipped : null)
                    : info.description,
                selected: isEquipped,
                locked: !frame.unlocked,
                initial: initial,
                onTap: frame.unlocked && !isEquipped
                    ? () => onSelect(frame.key)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FrameTile extends StatelessWidget {
  const _FrameTile({
    required this.frameKey,
    required this.title,
    required this.note,
    required this.selected,
    required this.locked,
    required this.initial,
    required this.onTap,
  });

  final String frameKey;
  final String title;
  final String? note;
  final bool selected;
  final bool locked;
  final String initial;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    // The InkWell wraps the tile and its labels so the whole item is tappable.
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: title,
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        onTap: onTap,
        child: SizedBox(
          width: 124,
          child: Padding(
            padding: EdgeInsets.all(tokens.spaceXs),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 100,
                  child: Center(
                    child: GameFrameTile(
                      equipped: selected,
                      locked: locked,
                      child: Center(
                        child: AvatarFrame(
                          size: 40,
                          frame: frameKey,
                          initial: initial,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: tokens.spaceXs),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color:
                        selected ? AppColors.textPrimary : AppColors.textMuted,
                  ),
                ),
                if (note != null)
                  Text(
                    note!,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color:
                          selected ? AppColors.accentGlow : AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Achievement cards with a progress bar; untracked ones say "coming soon".
class ProfileAchievementsSection extends StatelessWidget {
  const ProfileAchievementsSection({super.key, required this.items});

  final List<ProgressItem> items;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: l10n.profileAchievementsTitle),
        for (final item in items) _AchievementCard(item: item),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.item});

  final ProgressItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final info = achievementInfo(l10n, item.key, item.target);

    return GameAchievementCard(
      icon: info.asset == null
          ? const SizedBox.shrink()
          : Lottie.asset(
              'assets/lottie/badge_${info.asset}.json',
              repeat: false,
              fit: BoxFit.contain,
            ),
      title: info.title,
      subtitle: info.description,
      progress: item.current,
      goal: item.target <= 0 ? 1 : item.target,
      comingSoon: !item.available,
      comingSoonLabel: l10n.achComingSoon,
    );
  }
}

Future<void> showProfileBlockDialog(BuildContext context) {
  final l10n = context.l10n;

  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(l10n.profileBlockTitle),
      content: TextField(
        maxLines: 3,
        decoration: InputDecoration(hintText: l10n.profileBlockReasonHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l10n.profileBlockNo),
        ),
        GameButton(
          label: l10n.profileBlockYes,
          style: GameButtonStyle.dark,
          onPressed: null,
        ),
      ],
    ),
  );
}
