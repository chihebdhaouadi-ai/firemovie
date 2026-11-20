import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/game_button.dart';
import '../../../core/widgets/luxe_palette.dart';
import '../../../l10n/app_localizations.dart';
import '../../film_reviews/presentation/open_take.dart';
import '../../find/data/movie.dart';
import '../data/social_models.dart';
import '../data/social_repository.dart';

/// Which notifications a tab shows.
enum _Tab { all, takes, mentions, requests }

/// Your notifications, filtered by tab (All, Takes, Mentions, Requests) and
/// grouped: pending friend requests first, then what is new, then what came
/// earlier. Unread rows carry a dot; opening one marks it read, and Mark all
/// read clears them all. Friend requests are answered in place: Accept turns
/// the row into "You're now friends", Decline removes it with an Undo.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    required this.repository,
    required this.onOpenUser,
    this.onOpenTake,
  });

  final SocialRepository repository;
  final ValueChanged<SocialUser> onOpenUser;

  /// Opens the take a share or mention points to. Defaults to its page.
  final void Function(TakeRef take, int? commentId)? onOpenTake;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItem> _items = const [];

  /// Rows that were unread when the list loaded. They stay under "New" once
  /// opened, so nothing jumps between sections while you read.
  Set<int> _newAtLoad = const {};

  /// Friend requests accepted here; their row says "You're now friends".
  final Set<int> _accepted = {};
  final Set<int> _busy = {};
  _Tab _tab = _Tab.all;
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
        _newAtLoad = {
          for (final item in page.items)
            if (!item.read) item.id,
        };
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  bool _isRequest(NotificationItem item) =>
      item.kind == NotificationKind.friendRequest &&
      item.friendRequestId != null;

  bool _matches(NotificationItem item, _Tab tab) => switch (tab) {
        _Tab.all => true,
        _Tab.takes => item.kind == NotificationKind.takeShared,
        _Tab.mentions => item.kind == NotificationKind.takeMention,
        _Tab.requests => item.kind == NotificationKind.friendRequest,
      };

  int _unread(_Tab tab) =>
      _items.where((item) => !item.read && _matches(item, tab)).length;

  void _setRead(int id) => setState(() => _items = [
        for (final item in _items)
          item.id == id ? item.copyWith(read: true) : item,
      ]);

  /// Read state is cosmetic; a failed save just shows the dot again next time.
  Future<void> _markRead(NotificationItem item) async {
    if (item.read) return;
    _setRead(item.id);
    try {
      await widget.repository.markNotificationRead(item.id);
    } catch (_) {}
  }

  Future<void> _markAllRead() async {
    setState(
        () => _items = [for (final item in _items) item.copyWith(read: true)]);
    try {
      await widget.repository.markNotificationsRead();
    } catch (_) {}
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _open(NotificationItem item) {
    _markRead(item);
    final take = item.take;
    if (take == null) {
      widget.onOpenUser(item.actor);
      return;
    }
    final open = widget.onOpenTake;
    if (open != null) {
      open(take, item.commentId);
      return;
    }
    openTakeById(context, take.id, replyToCommentId: item.commentId);
  }

  Future<void> _accept(NotificationItem item) async {
    final requestId = item.friendRequestId;
    if (requestId == null || _busy.contains(item.id)) return;
    final l10n = context.l10n;
    setState(() => _busy.add(item.id));
    try {
      await widget.repository.acceptFriendRequest(requestId);
      if (!mounted) return;
      setState(() => _accepted.add(item.id));
      await _markRead(item);
    } catch (error) {
      if (!mounted) return;
      if (error is ServerFailure && error.code == 'not_found') {
        setState(() => _items = _items.where((i) => i.id != item.id).toList());
        _showSnack(l10n.friendRequestGone);
      } else {
        _showSnack(l10n.friendActionFailed);
      }
    } finally {
      if (mounted) setState(() => _busy.remove(item.id));
    }
  }

  /// Takes the request off the list at once, with Undo on the toast. The
  /// server only hears about it once the toast closes without Undo.
  void _decline(NotificationItem item) {
    final requestId = item.friendRequestId;
    if (requestId == null || _busy.contains(item.id)) return;
    final l10n = context.l10n;
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index < 0) return;
    final repository = widget.repository;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _items = [..._items]..removeAt(index));
    messenger.hideCurrentSnackBar();
    final toast = messenger.showSnackBar(SnackBar(
      content: Text(l10n.notificationsRequestDeclined(item.actor.username)),
      duration: const Duration(seconds: 4),
      // Close on its own even with Undo on it; the decline is sent then.
      persist: false,
      action: SnackBarAction(
        label: l10n.notificationsUndo,
        onPressed: () {
          if (!mounted) return;
          final at = index.clamp(0, _items.length);
          setState(() => _items = [..._items]..insert(at, item));
        },
      ),
    ));
    toast.closed.then((reason) async {
      if (reason == SnackBarClosedReason.action) return;
      try {
        await repository.declineFriendRequest(requestId);
      } catch (error) {
        final gone = error is ServerFailure && error.code == 'not_found';
        if (gone) return;
        if (mounted) {
          final at = index.clamp(0, _items.length);
          setState(() => _items = [..._items]..insert(at, item));
          messenger
              .showSnackBar(SnackBar(content: Text(l10n.friendActionFailed)));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final anyUnread = _unread(_Tab.all) > 0;

    return Scaffold(
      backgroundColor: LuxeColors.bg,
      appBar: AppBar(
        backgroundColor: LuxeColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          l10n.notificationsTitle,
          style: TextStyle(
            color: LuxeColors.text,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -.2,
          ),
        ),
        actions: [
          TextButton(
            key: const Key('notifications-mark-all'),
            onPressed: anyUnread && !_loading ? _markAllRead : null,
            style: TextButton.styleFrom(
              foregroundColor: LuxeColors.accent,
              disabledForegroundColor: LuxeColors.muted,
              textStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            child: Text(l10n.notificationsMarkAllRead),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Tabs(
                  selected: _tab,
                  unread: {for (final tab in _Tab.values) tab: _unread(tab)},
                  onSelect: (tab) => setState(() => _tab = tab),
                ),
                Expanded(child: _buildBody(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    if (_loading) {
      return Center(child: CircularProgressIndicator(color: LuxeColors.accent));
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
              style: TextStyle(color: LuxeColors.muted, fontSize: 14),
            ),
            SizedBox(height: tokens.spaceSm),
            GameButton(
              label: l10n.profileRetry,
              style: GameButtonStyle.blue,
              onPressed: _load,
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return _Empty(text: l10n.notificationsEmpty);
    }

    final shown = _items.where((item) => _matches(item, _tab)).toList();
    final requests = shown.where(_isRequest).toList();
    final rest = shown.where((item) => !_isRequest(item));
    final fresh = rest.where((item) => _newAtLoad.contains(item.id)).toList();
    final earlier =
        rest.where((item) => !_newAtLoad.contains(item.id)).toList();
    if (shown.isEmpty) return _Empty(text: l10n.notificationsNothingHere);

    Widget rowOf(NotificationItem item) {
      final busy = _busy.contains(item.id);
      final pending = _isRequest(item) && !_accepted.contains(item.id);
      return _NotificationRow(
        key: ValueKey('notification-${item.id}'),
        item: item,
        // Accepted here, or already answered (the server no longer sends the
        // request to answer).
        accepted: _accepted.contains(item.id) ||
            (item.kind == NotificationKind.friendRequest &&
                item.friendRequestId == null),
        onOpen: () => _open(item),
        onAccept: pending && !busy ? () => _accept(item) : null,
        onDecline: pending && !busy ? () => _decline(item) : null,
      );
    }

    return RefreshIndicator(
      color: LuxeColors.accent,
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 40),
        children: [
          for (final (title, group) in [
            (l10n.notificationsGroupRequests, requests),
            (l10n.notificationsGroupNew, fresh),
            (l10n.notificationsGroupEarlier, earlier),
          ])
            if (group.isNotEmpty) ...[
              _GroupHeading(title),
              for (var i = 0; i < group.length; i++) ...[
                rowOf(group[i]),
                if (i < group.length - 1)
                  Divider(height: 1, thickness: 1, color: LuxeColors.hair),
              ],
            ],
        ],
      ),
    );
  }
}

/// The filter tabs under the title, each with its unread count.
class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.selected,
    required this.unread,
    required this.onSelect,
  });

  final _Tab selected;
  final Map<_Tab, int> unread;
  final ValueChanged<_Tab> onSelect;

  String _label(AppLocalizations l10n, _Tab tab) => switch (tab) {
        _Tab.all => l10n.notificationsTabAll,
        _Tab.takes => l10n.notificationsTabTakes,
        _Tab.mentions => l10n.notificationsTabMentions,
        _Tab.requests => l10n.notificationsTabRequests,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: LuxeColors.hair)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            for (final tab in _Tab.values)
              _TabButton(
                key: Key('notifications-tab-${tab.name}'),
                label: _label(l10n, tab),
                count: unread[tab] ?? 0,
                selected: tab == selected,
                onTap: () => onSelect(tab),
              ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    super.key,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      selected: selected,
      button: true,
      label:
          count > 0 ? '$label, ${l10n.notificationsUnreadCount(count)}' : label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 46),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? LuxeColors.text : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected ? LuxeColors.text : LuxeColors.muted,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 5),
                Text(
                  '$count',
                  style: TextStyle(
                    color: LuxeColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupHeading extends StatelessWidget {
  const _GroupHeading(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 4),
        child: Semantics(
          header: true,
          child: Text(
            title,
            style: TextStyle(
              color: LuxeColors.muted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 70, horizontal: 22),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: LuxeColors.muted, fontSize: 14),
        ),
      );
}

/// One notification: the friend's photo with a small badge for the kind,
/// "**name** did something", the take or note it is about, and on the right
/// how long ago with an unread dot.
class _NotificationRow extends StatelessWidget {
  const _NotificationRow({
    super.key,
    required this.item,
    required this.accepted,
    required this.onOpen,
    this.onAccept,
    this.onDecline,
  });

  final NotificationItem item;
  final bool accepted;
  final VoidCallback onOpen;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  IconData get _badge => switch (item.kind) {
        NotificationKind.friendRequest => BootstrapIcons.person_plus,
        NotificationKind.friendAccepted => BootstrapIcons.person_check,
        NotificationKind.movieSuggestion => BootstrapIcons.film,
        NotificationKind.takeShared => BootstrapIcons.card_text,
        NotificationKind.takeMention => BootstrapIcons.at,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = item.actor.username;
    final suggestion = item.suggestion;
    final sentence = switch (item.kind) {
      NotificationKind.friendRequest => l10n.notificationFriendRequest(name),
      NotificationKind.friendAccepted => l10n.notificationFriendAccepted(name),
      NotificationKind.movieSuggestion =>
        l10n.notificationMovieSuggestion(name, suggestion?.title ?? ''),
      NotificationKind.takeShared => l10n.notificationTakeShared(name),
      NotificationKind.takeMention => l10n.notificationTakeMention(name),
    };
    final note =
        item.message.isNotEmpty ? item.message : (suggestion?.comment ?? '');
    final take = item.take;
    final takeBody = take?.body ?? '';
    final spoiler = take?.spoiler ?? false;
    final read = item.read;
    final createdAt = item.createdAt;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          _boldName(sentence, name),
          style: TextStyle(
            color: read ? LuxeColors.muted : LuxeColors.text,
            fontSize: 15,
            height: 1.4,
          ),
        ),
        if (takeBody.isNotEmpty || spoiler) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              if (spoiler) ...[
                Icon(BootstrapIcons.eye_slash_fill,
                    size: 15, color: LuxeColors.muted),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  // Spoilers stay hidden until the take is opened.
                  spoiler ? l10n.topicSpoilerLabel : l10n.reviewQuote(takeBody),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: LuxeColors.text,
                    fontSize: 17,
                    height: 1.4,
                    fontStyle: spoiler ? FontStyle.italic : null,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (note.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            l10n.reviewQuote(note),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: LuxeColors.muted, fontSize: 13),
          ),
        ],
        if (accepted)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.notificationsNowFriends,
              style: TextStyle(color: LuxeColors.muted, fontSize: 13),
            ),
          )
        else if (onAccept != null || onDecline != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: onAccept,
                  style: FilledButton.styleFrom(
                    backgroundColor: LuxeColors.text,
                    foregroundColor: LuxeColors.bg,
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  child: Text(l10n.friendAccept),
                ),
                OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: LuxeColors.text,
                    side: BorderSide(color: LuxeColors.hair),
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  child: Text(l10n.friendDecline),
                ),
              ],
            ),
          ),
      ],
    );

    return InkWell(
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BadgedAvatar(user: item.actor, badge: _badge),
            const SizedBox(width: 14),
            Expanded(child: body),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (createdAt != null)
                  Text(
                    _shortTime(l10n, createdAt),
                    style: TextStyle(color: LuxeColors.muted, fontSize: 12),
                  ),
                const SizedBox(height: 8),
                // The unread dot; its space stays so rows line up.
                Semantics(
                  label: read ? null : l10n.notificationsUnreadCount(1),
                  child: Container(
                    key: read ? null : Key('notification-unread-${item.id}'),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: read ? Colors.transparent : LuxeColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The sentence with the friend's name in bold; it works in any language
/// because it looks for the name inside the translated sentence.
TextSpan _boldName(String sentence, String name) {
  final at = name.isEmpty ? -1 : sentence.indexOf(name);
  if (at < 0) return TextSpan(text: sentence);
  return TextSpan(children: [
    TextSpan(text: sentence.substring(0, at)),
    TextSpan(
      text: name,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        color: LuxeColors.text,
      ),
    ),
    TextSpan(text: sentence.substring(at + name.length)),
  ]);
}

String _shortTime(AppLocalizations l10n, DateTime createdAt) {
  final now = DateTime.now();
  final elapsed = now.difference(createdAt);
  if (elapsed.inMinutes < 1) return l10n.notificationsTimeNow;
  if (elapsed.inHours < 1) {
    return l10n.notificationsTimeMinutes(elapsed.inMinutes);
  }
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(createdAt.year, createdAt.month, createdAt.day);
  final daysAgo = today.difference(day).inDays;
  if (daysAgo == 0) return l10n.notificationsTimeHours(elapsed.inHours);
  if (daysAgo == 1) return l10n.notificationsTimeYesterday;
  return l10n.notificationsTimeDays(daysAgo);
}

/// The friend's photo (or initial on a colour picked from their name) with a
/// small round badge for the kind of notification.
class _BadgedAvatar extends StatelessWidget {
  const _BadgedAvatar({required this.user, required this.badge});

  final SocialUser user;
  final IconData badge;

  static const _tints = [
    Color(0xFF3B4F7A),
    Color(0xFF7A6A5A),
    Color(0xFF5B7A6A),
    Color(0xFF7A5B6E),
    Color(0xFF4A4A4A),
    Color(0xFF6A5B8C),
  ];

  @override
  Widget build(BuildContext context) {
    final name = user.username;
    final avatar = user.avatarUrl;
    final tint = _tints[name.hashCode.abs() % _tints.length];
    return SizedBox.square(
      dimension: 46,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: tint,
            backgroundImage:
                avatar == null ? null : CachedNetworkImageProvider(avatar),
            child: avatar == null
                ? Text(
                    name.isEmpty ? '?' : name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          PositionedDirectional(
            end: -4,
            bottom: -4,
            child: ExcludeSemantics(
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: LuxeColors.bg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(badge, size: 12, color: LuxeColors.text),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
