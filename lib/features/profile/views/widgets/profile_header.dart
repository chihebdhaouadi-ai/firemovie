import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../social/data/social_models.dart';
import '../../data/profile_models.dart';
import '../../data/profile_placeholders.dart';

class ProfileBanner extends StatelessWidget {
  const ProfileBanner({
    super.key,
    required this.username,
    this.avatarUrl,
    this.coverUrl,
    this.onMore,
    this.onEditAvatar,
    this.onEditCover,
  });

  final String username;
  final String? avatarUrl;
  final String? coverUrl;
  final VoidCallback? onMore;
  final VoidCallback? onEditAvatar;
  final VoidCallback? onEditCover;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final cover = coverUrl;
    final initial = username.isEmpty ? '' : username.substring(0, 1);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          child: SizedBox(
            height: 128,
            width: double.infinity,
            child: cover == null
                ? const ColoredBox(color: AppColors.panelBorder)
                : CachedNetworkImage(
                    imageUrl: cover,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        const ColoredBox(color: AppColors.panelBorder),
                  ),
          ),
        ),
        if (onMore != null)
          PositionedDirectional(
            top: 0,
            end: 0,
            child: IconButton(
              tooltip: l10n.profileMoreTooltip,
              onPressed: onMore,
              icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            ),
          ),
        if (onEditCover != null)
          PositionedDirectional(
            bottom: tokens.spaceXs,
            end: tokens.spaceXs,
            child: IconButton.filledTonal(
              tooltip: l10n.profileEditCover,
              onPressed: onEditCover,
              icon: const Icon(Icons.image_outlined),
            ),
          ),
        PositionedDirectional(
          start: tokens.spaceMd,
          bottom: -tokens.minTouchTarget,
          child: _AvatarBadge(
            avatarUrl: avatarUrl,
            initial: initial.toUpperCase(),
            onEdit: onEditAvatar,
          ),
        ),
      ],
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({
    required this.avatarUrl,
    required this.initial,
    this.onEdit,
  });

  final String? avatarUrl;
  final String initial;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final avatar = avatarUrl;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.background,
          ),
          child: Padding(
            padding: EdgeInsets.all(tokens.borderWidth * 2),
            child: CircleAvatar(
              radius: tokens.minTouchTarget,
              backgroundColor: AppColors.surfaceRaised,
              backgroundImage:
                  avatar == null ? null : CachedNetworkImageProvider(avatar),
              child: avatar == null
                  ? Text(
                      initial,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColors.accentGlow,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        if (onEdit != null)
          PositionedDirectional(
            end: -tokens.spaceXs,
            bottom: -tokens.spaceXs,
            child: IconButton.filled(
              tooltip: l10n.profileEditPhoto,
              onPressed: onEdit,
              icon: const Icon(Icons.camera_alt_outlined, size: 18),
            ),
          ),
      ],
    );
  }
}

class ProfileCountPills extends StatelessWidget {
  const ProfileCountPills({
    super.key,
    required this.followers,
    required this.following,
  });

  final int followers;
  final int following;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _CountPill(label: l10n.profileFollowers, value: followers),
        SizedBox(width: tokens.spaceSm),
        _CountPill(label: l10n.profileFollowing, value: following),
      ],
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        border: Border.all(
          color: AppColors.outline,
          width: tokens.borderWidth,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spaceMd,
          vertical: tokens.spaceSm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$value',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileIdentity extends StatelessWidget {
  const ProfileIdentity({
    super.key,
    required this.username,
    this.bio = '',
    this.onEditBio,
  });

  final String username;
  final String bio;
  final VoidCallback? onEditBio;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                username,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(width: tokens.spaceXs),
            Icon(
              Icons.flag_outlined,
              size: tokens.iconSmall,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: tokens.spaceXs),
            Text(
              ProfilePlaceholders.tag,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.spaceXs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: tokens.spaceSm),
                child: Text(
                  bio.isEmpty ? l10n.profileBioHint : bio,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color:
                        bio.isEmpty ? AppColors.textMuted : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            if (onEditBio != null)
              IconButton(
                tooltip: l10n.profileEditBio,
                onPressed: onEditBio,
                icon: const Icon(Icons.edit_outlined),
              ),
          ],
        ),
      ],
    );
  }
}

class FriendActionRow extends StatelessWidget {
  const FriendActionRow({
    super.key,
    required this.state,
    required this.busy,
    required this.onAdd,
    required this.onCancel,
    required this.onAccept,
    required this.onDecline,
    this.onSuggest,
  });

  final Friendship state;
  final bool busy;
  final VoidCallback onAdd;
  final VoidCallback onCancel;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback? onSuggest;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final fullWidth = Size(double.infinity, tokens.minTouchTarget);
    final minSize = Size(0, tokens.minTouchTarget);

    return switch (state) {
      Friendship.self => const SizedBox.shrink(),
      Friendship.none => FilledButton.icon(
          onPressed: busy ? null : onAdd,
          icon: const Icon(Icons.person_add_alt_1_outlined),
          style: FilledButton.styleFrom(minimumSize: fullWidth),
          label: Text(l10n.friendAdd),
        ),
      Friendship.outgoing => OutlinedButton(
          onPressed: busy ? null : onCancel,
          style: OutlinedButton.styleFrom(minimumSize: fullWidth),
          child: Text(l10n.friendCancelRequest),
        ),
      Friendship.incoming => Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: busy ? null : onAccept,
                style: FilledButton.styleFrom(minimumSize: minSize),
                child: Text(l10n.friendAccept),
              ),
            ),
            SizedBox(width: tokens.spaceSm),
            Expanded(
              child: OutlinedButton(
                onPressed: busy ? null : onDecline,
                style: OutlinedButton.styleFrom(minimumSize: minSize),
                child: Text(l10n.friendDecline),
              ),
            ),
          ],
        ),
      Friendship.friends when onSuggest != null => Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.people_alt_outlined),
                style: OutlinedButton.styleFrom(minimumSize: minSize),
                label: Text(l10n.friendFriends),
              ),
            ),
            SizedBox(width: tokens.spaceSm),
            Expanded(
              child: FilledButton.icon(
                onPressed: busy ? null : onSuggest,
                icon: const Icon(Icons.movie_filter_outlined),
                style: FilledButton.styleFrom(minimumSize: minSize),
                label: Text(l10n.suggestMovieAction),
              ),
            ),
          ],
        ),
      Friendship.friends => OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.people_alt_outlined),
          style: OutlinedButton.styleFrom(minimumSize: fullWidth),
          label: Text(l10n.friendFriends),
        ),
    };
  }
}

class ConnectionsSection extends StatelessWidget {
  const ConnectionsSection({
    super.key,
    required this.following,
    required this.followers,
    required this.onOpen,
  });

  final List<SocialUser> following;
  final List<SocialUser> followers;
  final ValueChanged<SocialUser> onOpen;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ConnectionGroup(
          title: l10n.profileFollowing,
          users: following,
          onOpen: onOpen,
        ),
        SizedBox(height: tokens.spaceLg),
        _ConnectionGroup(
          title: l10n.profileFollowers,
          users: followers,
          onOpen: onOpen,
        ),
      ],
    );
  }
}

class _ConnectionGroup extends StatelessWidget {
  const _ConnectionGroup({
    required this.title,
    required this.users,
    required this.onOpen,
  });

  final String title;
  final List<SocialUser> users;
  final ValueChanged<SocialUser> onOpen;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: tokens.spaceSm),
        if (users.isEmpty)
          Text(
            l10n.profileNoConnections,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
            ),
          )
        else
          Wrap(
            spacing: tokens.spaceSm,
            runSpacing: tokens.spaceSm,
            children: [
              for (final user in users)
                ActionChip(
                  avatar: _ChipAvatar(user: user),
                  label: Text(user.username),
                  onPressed: () => onOpen(user),
                ),
            ],
          ),
      ],
    );
  }
}

class _ChipAvatar extends StatelessWidget {
  const _ChipAvatar({required this.user});

  final SocialUser user;

  @override
  Widget build(BuildContext context) {
    final avatar = user.avatarUrl;
    final initial = user.username.isEmpty
        ? ''
        : user.username.substring(0, 1).toUpperCase();

    return CircleAvatar(
      radius: 12,
      backgroundColor: AppColors.surfaceRaised,
      backgroundImage:
          avatar == null ? null : CachedNetworkImageProvider(avatar),
      child: avatar == null
          ? Text(
              initial,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.accentGlow,
                  ),
            )
          : null,
    );
  }
}
