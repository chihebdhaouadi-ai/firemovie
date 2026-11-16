import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../social/data/social_models.dart';
import '../../data/profile_models.dart';
import '../../../../core/widgets/game_button.dart';
import 'profile_game_kit.dart';

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

    return switch (state) {
      Friendship.self => const SizedBox.shrink(),
      Friendship.none => SizedBox(
          width: double.infinity,
          child: GameButton(
            onPressed: busy ? null : onAdd,
            icon: Icons.person_add_alt_1_outlined,
            label: l10n.friendAdd,
            style: GameButtonStyle.blue,
          ),
        ),
      Friendship.outgoing => SizedBox(
          width: double.infinity,
          child: GameButton(
            onPressed: busy ? null : onCancel,
            label: l10n.friendCancelRequest,
          ),
        ),
      Friendship.incoming => Row(
          children: [
            Expanded(
              child: GameButton(
                onPressed: busy ? null : onAccept,
                label: l10n.friendAccept,
                style: GameButtonStyle.blue,
              ),
            ),
            SizedBox(width: tokens.spaceSm),
            Expanded(
              child: GameButton(
                onPressed: busy ? null : onDecline,
                label: l10n.friendDecline,
              ),
            ),
          ],
        ),
      Friendship.friends when onSuggest != null => Row(
          children: [
            Expanded(
              child: GameButton(
                onPressed: null,
                icon: Icons.people_alt_outlined,
                label: l10n.friendFriends,
              ),
            ),
            SizedBox(width: tokens.spaceSm),
            Expanded(
              child: GameButton(
                onPressed: busy ? null : onSuggest,
                icon: Icons.movie_filter_outlined,
                label: l10n.suggestMovieAction,
                style: GameButtonStyle.blue,
              ),
            ),
          ],
        ),
      Friendship.friends => SizedBox(
          width: double.infinity,
          child: GameButton(
            onPressed: null,
            icon: Icons.people_alt_outlined,
            label: l10n.friendFriends,
          ),
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
                GameChip(
                  avatar: user.avatarUrl == null
                      ? null
                      : CachedNetworkImageProvider(user.avatarUrl!),
                  label: user.username,
                  onTap: () => onOpen(user),
                ),
            ],
          ),
      ],
    );
  }
}
