import 'package:flutter/material.dart';

import '../../../../core/avatar_frames.dart';
import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/avatar_frame.dart';
import '../../data/profile_models.dart';
import '../../../../core/widgets/game_button.dart';
import 'profile_game_kit.dart';

/// Centre-aligned header: framed avatar, name, level and XP, bio.
class ProfileHero extends StatelessWidget {
  const ProfileHero({
    super.key,
    required this.username,
    required this.progress,
    this.avatarUrl,
    this.frame = defaultFrameKey,
    this.bio = '',
    this.onEditAvatar,
    this.onEditBio,
  });

  static const avatarSize = 112.0;

  final String username;
  final String? avatarUrl;
  final String frame;
  final ProfileProgress progress;
  final String bio;
  final VoidCallback? onEditAvatar;
  final VoidCallback? onEditBio;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final initial = username.isEmpty ? '' : username.substring(0, 1);

    return Column(
      children: [
        // The frame ring overlays ~45% beyond the avatar on each side.
        Padding(
          padding: EdgeInsets.symmetric(vertical: avatarSize * 0.45),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              AvatarFrame(
                size: avatarSize,
                frame: frame,
                avatarUrl: avatarUrl,
                initial: initial,
              ),
              if (onEditAvatar != null)
                PositionedDirectional(
                  end: -tokens.spaceXs,
                  bottom: -tokens.spaceXs,
                  child: GameIconButton(
                    tooltip: l10n.profileEditPhoto,
                    onPressed: onEditAvatar,
                    style: GameButtonStyle.blue,
                    icon: Icons.camera_alt_outlined,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
        Text(
          username,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: tokens.spaceXs),
        LevelPill(
          level: progress.level,
          label: l10n.profileLevelLabel(progress.level),
        ),
        SizedBox(height: tokens.spaceSm),
        SizedBox(
          width: 220,
          child: GameProgressBar(value: progress.levelFraction),
        ),
        SizedBox(height: tokens.spaceXs),
        Text(
          l10n.profileXpProgress(
            progress.xpIntoLevel,
            progress.xpForNextLevel,
            progress.level + 1,
          ),
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        SizedBox(height: tokens.spaceMd),
        _Bio(bio: bio, onEdit: onEditBio),
      ],
    );
  }
}

class _Bio extends StatelessWidget {
  const _Bio({required this.bio, this.onEdit});

  final String bio;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final hasBio = bio.isNotEmpty;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            hasBio ? bio : l10n.profileBioHint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: hasBio ? AppColors.textSecondary : AppColors.textMuted,
            ),
          ),
        ),
        if (onEdit != null) ...[
          SizedBox(width: tokens.spaceXs),
          IconButton(
            tooltip: l10n.profileEditBio,
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 18),
          ),
        ],
      ],
    );
  }
}
