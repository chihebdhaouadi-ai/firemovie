import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../find/data/movie.dart';
import '../data/social_models.dart';
import '../data/social_repository.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    required this.repository,
    required this.onOpenUser,
  });

  final SocialRepository repository;
  final ValueChanged<SocialUser> onOpenUser;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItem> _items = const [];
  final Set<int> _busy = {};
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final page = await widget.repository.notifications();
      if (!mounted) return;
      setState(() {
        _items = page.items;
        _loading = false;
      });
      _markRead();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  Future<void> _markRead() async {
    try {
      await widget.repository.markNotificationsRead();
    } catch (_) {
      // Read state is cosmetic here; the next load will try again.
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _removeItem(int id) {
    setState(() => _items = _items.where((item) => item.id != id).toList());
  }

  Future<void> _respond(NotificationItem item, {required bool accept}) async {
    final requestId = item.friendRequestId;
    if (requestId == null || _busy.contains(item.id)) return;
    final l10n = context.l10n;
    setState(() => _busy.add(item.id));
    try {
      if (accept) {
        await widget.repository.acceptFriendRequest(requestId);
      } else {
        await widget.repository.declineFriendRequest(requestId);
      }
      if (!mounted) return;
      _removeItem(item.id);
    } catch (error) {
      if (!mounted) return;
      if (error is ServerFailure && error.code == 'not_found') {
        _removeItem(item.id);
        _showSnack(l10n.friendRequestGone);
      } else {
        _showSnack(l10n.friendActionFailed);
      }
    } finally {
      if (mounted) setState(() => _busy.remove(item.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.notificationsTitle),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
            child: _buildBody(context),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final theme = Theme.of(context);

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accentGlow),
      );
    }

    if (_failed) {
      return Padding(
        padding: EdgeInsets.all(tokens.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.notificationsFailed,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: tokens.spaceSm),
            FilledButton(
              onPressed: _load,
              child: Text(l10n.profileRetry),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(tokens.spaceLg),
        child: Text(
          l10n.notificationsEmpty,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg),
      itemCount: _items.length,
      separatorBuilder: (_, __) => SizedBox(height: tokens.spaceSm),
      itemBuilder: (context, index) {
        final item = _items[index];
        final actionable = item.kind == NotificationKind.friendRequest &&
            item.friendRequestId != null;
        final busy = _busy.contains(item.id);
        return _NotificationTile(
          item: item,
          onOpen: () => widget.onOpenUser(item.actor),
          onAccept: actionable && !busy
              ? () => _respond(item, accept: true)
              : null,
          onDecline: actionable && !busy
              ? () => _respond(item, accept: false)
              : null,
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.onOpen,
    this.onAccept,
    this.onDecline,
  });

  final NotificationItem item;
  final VoidCallback onOpen;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final avatar = item.actor.avatarUrl;
    final name = item.actor.username;
    final suggestion = item.suggestion;
    final message = switch (item.kind) {
      NotificationKind.friendRequest => l10n.notificationFriendRequest(name),
      NotificationKind.friendAccepted => l10n.notificationFriendAccepted(name),
      NotificationKind.movieSuggestion => l10n.notificationMovieSuggestion(
          name,
          suggestion?.title ?? '',
        ),
    };
    final comment = suggestion?.comment ?? '';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onOpen,
              borderRadius: BorderRadius.circular(tokens.radiusSm),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.background,
                    backgroundImage: avatar == null
                        ? null
                        : CachedNetworkImageProvider(avatar),
                    child: avatar == null
                        ? Text(
                            name.isEmpty ? '' : name.substring(0, 1).toUpperCase(),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppColors.accentGlow,
                            ),
                          )
                        : null,
                  ),
                  SizedBox(width: tokens.spaceSm),
                  Expanded(
                    child: Text(
                      message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: item.read
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (comment.isNotEmpty) ...[
              SizedBox(height: tokens.spaceSm),
              Text(
                comment,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (onAccept != null && onDecline != null) ...[
              SizedBox(height: tokens.spaceSm),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: onAccept,
                      style: FilledButton.styleFrom(
                        minimumSize: Size(0, tokens.minTouchTarget),
                      ),
                      child: Text(l10n.friendAccept),
                    ),
                  ),
                  SizedBox(width: tokens.spaceSm),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDecline,
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(0, tokens.minTouchTarget),
                      ),
                      child: Text(l10n.friendDecline),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
