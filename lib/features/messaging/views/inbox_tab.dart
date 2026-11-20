import 'package:cached_network_image/cached_network_image.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/auth/sign_in_prompt.dart';
import '../../../core/l10n_context.dart';
import '../../../core/motion.dart' show scrollEffectsEnabled;
import '../../../core/widgets/luxe_palette.dart';
import '../../../core/widgets/scroll_exit_effect.dart';
import '../../home/views/widgets/take_summary_card.dart' show relativeTakeTime;
import '../../profile/views/profile_screen.dart';
import '../../social/data/social_models.dart';
import '../../social/data/social_repository.dart';
import '../../social/views/user_search_screen.dart';
import '../data/messaging_models.dart';
import '../data/messaging_repository.dart';
import 'chat_message_tile.dart' show messageSnippet, systemText;
import 'chat_options.dart';
import 'chat_screen.dart';
import 'conversation_avatar.dart';
import 'inbox_sheets.dart';
import '../../../core/stable_image_key.dart';

/// How often the inbox list refreshes while it is open.
const inboxPollInterval = Duration(seconds: 15);

/// From this width (tablets, desktop web) the inbox shows the list and the
/// open chat side by side instead of opening chats as separate pages.
const inboxTwoPaneWidth = 760.0;

/// Width of the conversation list in the two-pane layout.
const _listPaneWidth = 340.0;

/// Height of the search / unread / add friend / + row.
const inboxActionsHeight = 31.0;

/// Lets a parent show the inbox's action row somewhere else, such as pinned
/// under the home tabs so it stays put while the chats scroll, while the
/// inbox keeps owning the search text, the unread filter and the actions.
class InboxActionsController extends ChangeNotifier {
  Widget Function(BuildContext context, double scale)? _builder;

  /// Whether an inbox is attached and has a row to show.
  bool get attached => _builder != null;

  /// The attached inbox's action row at [scale], or nothing.
  Widget build(BuildContext context, {double scale = 1}) =>
      _builder?.call(context, scale) ?? const SizedBox.shrink();

  void _attach(Widget Function(BuildContext context, double scale) builder) {
    _builder = builder;
    _changed();
  }

  void _detach(Widget Function(BuildContext context, double scale) builder) {
    if (_builder != builder) return;
    _builder = null;
    _changed();
  }

  bool _disposed = false;

  /// Attaching, detaching and inbox rebuilds happen mid-build, so listeners
  /// hear about them after the frame.
  void _changed() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// The inbox action row from [controller], sized for a pinned bar: it spans
/// the width on phones and lines up with the chat list in the two-pane
/// layout.
class InboxPinnedActions extends StatelessWidget {
  const InboxPinnedActions({
    super.key,
    required this.controller,
    this.scale = 1,
  });

  final InboxActionsController controller;

  /// Below 1 while the bar is shrunk by scrolling.
  final double scale;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) => ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final row = controller.build(context, scale: scale);
            if (box.maxWidth < inboxTwoPaneWidth) return row;
            return Align(
              alignment: AlignmentDirectional.centerStart,
              child: SizedBox(width: _listPaneWidth, child: row),
            );
          },
        ),
      );
}

/// The pinned bar holding the inbox action row. It is opaque and draws a
/// hairline once chats pass beneath, so its bottom edge is where the list
/// disappears; the row shrinks a little as soon as the chats reach it.
class InboxActionsBarDelegate extends SliverPersistentHeaderDelegate {
  const InboxActionsBarDelegate({
    required this.controller,
    required this.verticalPadding,
    required this.horizontalPadding,
    required this.background,
    this.shrinkStart = 0,
  });

  final InboxActionsController controller;

  /// Space above and below the row at full size.
  final double verticalPadding;
  final double horizontalPadding;
  final Color background;

  /// Scroll offset at which the chats first reach the bar (headers above it
  /// may collapse first); the row starts shrinking from there.
  final double shrinkStart;

  /// How small the row gets, as a fraction of its full size. 1: it keeps its
  /// size while the chats scroll under it.
  static const minScale = 1.0;

  /// Scroll distance over which the row shrinks.
  static const shrinkDistance = 48.0;

  @override
  double get maxExtent => inboxActionsHeight + verticalPadding * 2;

  @override
  double get minExtent => maxExtent;

  /// How far the row has shrunk (0 at rest, 1 fully) at [pixels].
  /// Always 0 on web, where the row stays still while scrolling.
  double progressAt(double pixels) => scrollEffectsEnabled
      ? ((pixels - shrinkStart) / shrinkDistance).clamp(0.0, 1.0)
      : 0.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final position =
        scrollEffectsEnabled ? Scrollable.maybeOf(context)?.position : null;
    Widget bar(double pixels) {
      final t = progressAt(pixels);
      final scale = 1 - (1 - minScale) * t;
      return DecoratedBox(
        key: const Key('inbox-actions-bar'),
        decoration: BoxDecoration(
          color: background,
          border: Border(
            bottom: BorderSide(
              color: t > 0 ? LuxeColors.hair : Colors.transparent,
            ),
          ),
        ),
        child: SizedBox(
          height: maxExtent,
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: horizontalPadding,
            ),
            child: Center(
              child: InboxPinnedActions(controller: controller, scale: scale),
            ),
          ),
        ),
      );
    }

    if (position == null) return bar(0);
    return ListenableBuilder(
      listenable: position,
      builder: (context, _) => bar(position.hasPixels ? position.pixels : 0),
    );
  }

  @override
  bool shouldRebuild(covariant InboxActionsBarDelegate oldDelegate) =>
      oldDelegate.controller != controller ||
      oldDelegate.verticalPadding != verticalPadding ||
      oldDelegate.horizontalPadding != horizontalPadding ||
      oldDelegate.background != background ||
      oldDelegate.shrinkStart != shrinkStart;
}

/// The Inbox tab: a rail of group chats, search / unread / add friend / new
/// chat actions, the private topics card and the list of conversations.
class InboxTab extends StatefulWidget {
  const InboxTab({
    super.key,
    required this.exitInset,
    required this.repository,
    required this.meId,
    this.social,
    this.signedIn = true,
    this.active = true,
    this.onUnreadChanged,
    this.onConversationsChanged,
    this.actionsController,
  });

  final ExitInset exitInset;
  final MessagingRepository repository;
  final SocialRepository? social;
  final int? meId;
  final bool signedIn;

  /// False while the tab is hidden (kept alive behind another tab): the
  /// list stops checking for new messages until it is shown again.
  final bool active;

  /// Total unread messages, reported after every refresh.
  final ValueChanged<int>? onUnreadChanged;

  /// Every chat, reported after every refresh (the home screen's group rail
  /// shows the groups).
  final ValueChanged<List<Conversation>>? onConversationsChanged;

  /// When set, the action row is handed to this controller for the parent
  /// to place (pinned under the home tabs) instead of sitting above the list.
  final InboxActionsController? actionsController;

  @override
  State<InboxTab> createState() => _InboxTabState();
}

class _InboxTabState extends State<InboxTab> {
  List<Conversation> _conversations = const [];
  bool _loading = true;
  bool _failed = false;
  bool _searching = false;
  bool _unreadOnly = false;
  String _query = '';
  Timer? _poll;

  /// The chat open in the right pane (two-pane layout only).
  Conversation? _selected;

  /// Whether the last layout had room for two panes.
  bool _wide = false;

  @override
  void initState() {
    super.initState();
    widget.actionsController?._attach(_buildActions);
    if (widget.signedIn) {
      unawaited(_load());
      _poll = Timer.periodic(inboxPollInterval, (_) {
        if (widget.active) unawaited(_load());
      });
    }
  }

  @override
  void didUpdateWidget(covariant InboxTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.actionsController != widget.actionsController) {
      oldWidget.actionsController?._detach(_buildActions);
      widget.actionsController?._attach(_buildActions);
    }
    // Shown again after a while: catch up straight away.
    if (widget.active && !oldWidget.active && widget.signedIn) {
      unawaited(_load());
    }
  }

  @override
  void dispose() {
    widget.actionsController?._detach(_buildActions);
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final conversations = await widget.repository.conversations();
      if (!mounted) return;
      setState(() {
        _conversations = conversations;
        _loading = false;
        _failed = false;
      });
      widget.onUnreadChanged?.call(_unreadIn(conversations));
      widget.onConversationsChanged?.call(conversations);
    } on Exception {
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = _conversations.isEmpty;
        });
      }
    }
  }

  /// Unread messages for the badges; muted chats don't count.
  static int _unreadIn(List<Conversation> conversations) => conversations
      .where((c) => !c.muted)
      .fold<int>(0, (sum, c) => sum + c.unread);

  int get _unread => _unreadIn(_conversations);

  List<Conversation> get _topics =>
      _conversations.where((c) => c.isTopic).toList();

  List<Conversation> get _visible {
    final query = _query.trim().toLowerCase();
    return _conversations
        .where((c) => !c.isTopic)
        .where((c) => query.isEmpty || c.title.toLowerCase().contains(query))
        .where((c) => !_unreadOnly || c.looksUnread)
        .toList();
  }

  Future<void> _open(Conversation conversation) async {
    setState(() {
      _conversations = [
        for (final c in _conversations)
          c.id == conversation.id
              ? c.copyWith(unread: 0, markedUnread: false)
              : c,
      ];
      if (_wide) _selected = conversation;
    });
    // Wide layout: the chat opens in the right pane.
    if (_wide) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ChatScreen(
          conversation: conversation,
          repository: widget.repository,
          meId: widget.meId,
          loadFriends: friendLoader(widget.social),
        ),
      ),
    );
    if (mounted) unawaited(_load());
  }

  Future<List<SocialUser>> _friends() async {
    final social = widget.social;
    if (social == null) return const [];
    try {
      return (await social.connections()).friends;
    } on Exception {
      return const [];
    }
  }

  Future<void> _addFriend() async {
    final social = widget.social;
    if (social == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => UserSearchScreen(
          repository: social,
          onOpenUser: (user) => Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) =>
                  ProfileScreen(userId: user.id, socialRepository: social),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _create() async {
    final choice = await showCreateMenu(context);
    if (!mounted || choice == null) return;
    switch (choice) {
      case InboxCreate.message:
        await _newMessage();
      case InboxCreate.group:
        await _newGroup(ConversationKind.group);
      case InboxCreate.topic:
        await _newGroup(ConversationKind.topic);
      case InboxCreate.blocked:
        await showBlockedSheet(context, repository: widget.repository);
        if (mounted) unawaited(_load());
    }
  }

  /// Hold (or right-click) a chat: pin, mute, mark unread, clear, and for a
  /// direct chat block or delete.
  Future<void> _options(Conversation conversation) async {
    final option = await showChatOptionsSheet(
      context,
      conversation: conversation,
      meId: widget.meId,
    );
    if (!mounted || option == null) return;
    final result = await runChatOption(
      context,
      option: option,
      conversation: conversation,
      meId: widget.meId,
      repository: widget.repository,
    );
    if (!mounted || result == null) return;
    setState(() {
      switch (result) {
        case ChatUpdated(conversation: final updated):
          _conversations = [
            for (final c in _conversations) c.id == updated.id ? updated : c,
          ];
        case ChatRemoved():
          _conversations =
              _conversations.where((c) => c.id != conversation.id).toList();
          if (_selected?.id == conversation.id) _selected = null;
      }
    });
    unawaited(_load());
  }

  Future<void> _newMessage() async {
    final friends = await _friends();
    if (!mounted) return;
    final friend = await pickFriend(context, friends);
    if (!mounted || friend == null) return;
    await _run(() => widget.repository.openDirect(friend.id));
  }

  Future<void> _newGroup(ConversationKind kind) async {
    final friends = await _friends();
    if (!mounted) return;
    final choice = await pickGroup(context, kind: kind, friends: friends);
    if (!mounted || choice == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final photoFailed = context.l10n.inboxPhotoFailed;
    await _run(() async {
      final created = await widget.repository.create(
        kind: kind,
        title: choice.title,
        memberIds: choice.memberIds,
        description: choice.description,
      );
      final photo = choice.photo;
      if (photo == null) return created;
      try {
        return await widget.repository.setPhoto(created.id, photo);
      } on Exception {
        // The chat exists; only the picture is missing.
        messenger.showSnackBar(SnackBar(content: Text(photoFailed)));
        return created;
      }
    });
  }

  /// Creates or finds a chat, then opens it.
  Future<void> _run(Future<Conversation> Function() action) async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = context.l10n.inboxCreateFailed;
    try {
      final conversation = await action();
      if (!mounted) return;
      unawaited(_load());
      await _open(conversation);
    } on Exception {
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    }
  }

  void _openTopics() {
    unawaited(showTopicsSheet(
      context,
      topics: _topics,
      onOpen: _open,
      onNew: () => _newGroup(ConversationKind.topic),
    ));
  }

  Widget _buildActions(BuildContext context, [double scale = 1]) =>
      InboxActions(
        scale: scale,
        searching: _searching,
        unreadCount: _unread,
        unreadOnly: _unreadOnly,
        onSearchOpen: () => setState(() => _searching = true),
        onSearchClose: () => setState(() {
          _searching = false;
          _query = '';
        }),
        onQuery: (value) => setState(() => _query = value),
        onToggleUnread: () => setState(() => _unreadOnly = !_unreadOnly),
        onAddFriend: _addFriend,
        onCreate: _create,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pinned = widget.actionsController;
    if (pinned != null) {
      // The pinned row is built by the parent; refresh it after this build.
      pinned._changed();
    }
    if (!widget.signedIn) {
      return ScrollExitEffect(
        exitInset: widget.exitInset,
        maxShrink: 0,
        child: SignInPrompt(
          title: l10n.authGuestPromptTitle,
          body: l10n.authGuestPromptBody,
          reason: l10n.authReasonHome,
        ),
      );
    }

    final visible = _visible;
    final Widget list;
    if (_loading) {
      list = const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (_failed) {
      list = _Message(
        title: l10n.inboxLoadFailed,
        action: TextButton(
          onPressed: () {
            setState(() => _loading = true);
            unawaited(_load());
          },
          child: Text(l10n.homeSectionErrorRetry),
        ),
      );
    } else if (_conversations.where((c) => !c.isTopic).isEmpty) {
      list = _Message(title: l10n.inboxEmptyTitle, body: l10n.inboxEmptyBody);
    } else if (visible.isEmpty) {
      list = _Message(title: l10n.inboxNoResults);
    } else {
      list = Column(
        children: [
          for (final conversation in visible)
            ConversationTile(
              key: ValueKey('conversation-${conversation.id}'),
              conversation: conversation,
              meId: widget.meId,
              selected: _wide && conversation.id == _selected?.id,
              onTap: () => _open(conversation),
              onOptions: () => _options(conversation),
            ),
        ],
      );
    }

    final listPane = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (pinned == null) ...[
          ScrollExitEffect(
            exitInset: widget.exitInset,
            maxShrink: 0,
            child: _buildActions(context),
          ),
          const SizedBox(height: 10),
        ],
        if (_query.isEmpty)
          ScrollExitEffect(
            exitInset: widget.exitInset,
            maxShrink: 0,
            child: PrivateTopicsCard(
              topics: _topics,
              meId: widget.meId,
              onTap: _openTopics,
            ),
          ),
        const SizedBox(height: 4),
        // Chats fade under the header but keep their width.
        ScrollExitEffect(
          exitInset: widget.exitInset,
          maxShrink: 0,
          child: list,
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, box) {
        _wide = box.maxWidth >= inboxTwoPaneWidth;
        if (!_wide) return listPane;
        final selected = _selected;
        // The chat pane fills the window down to just above the bottom
        // bar, and stays at least tall enough to read a conversation.
        final paneHeight =
            (MediaQuery.sizeOf(context).height - 340).clamp(420.0, 900.0);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: _listPaneWidth, child: listPane),
            const SizedBox(width: 20),
            Expanded(
              child: SizedBox(
                height: paneHeight,
                child: selected == null
                    ? _EmptyPane(text: l10n.inboxSelectChat)
                    : ChatScreen(
                        key: ValueKey('chat-pane-${selected.id}'),
                        conversation: selected,
                        repository: widget.repository,
                        meId: widget.meId,
                        embedded: true,
                        loadFriends: friendLoader(widget.social),
                        onLeft: () {
                          setState(() => _selected = null);
                          unawaited(_load());
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The right pane before a chat is picked.
class _EmptyPane extends StatelessWidget {
  const _EmptyPane({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        key: const Key('chat-pane-empty'),
        decoration: BoxDecoration(
          color: LuxeColors.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: LuxeColors.hair),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(BootstrapIcons.chat_square_text,
                  size: 34, color: LuxeColors.muted),
              const SizedBox(height: 8),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(color: LuxeColors.muted, fontSize: 11),
              ),
            ],
          ),
        ),
      );
}

/// Search, the unread filter, add friend and the + button; search turns the
/// row into a text field.
class InboxActions extends StatelessWidget {
  const InboxActions({
    super.key,
    required this.searching,
    required this.unreadCount,
    required this.unreadOnly,
    required this.onSearchOpen,
    required this.onSearchClose,
    required this.onQuery,
    required this.onToggleUnread,
    required this.onAddFriend,
    required this.onCreate,
    this.scale = 1,
  });

  final bool searching;
  final int unreadCount;
  final bool unreadOnly;
  final VoidCallback onSearchOpen;
  final VoidCallback onSearchClose;
  final ValueChanged<String> onQuery;
  final VoidCallback onToggleUnread;
  final VoidCallback onAddFriend;
  final VoidCallback onCreate;

  /// Shrinks the whole row (the pinned bar uses it as the chats scroll).
  final double scale;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      height: inboxActionsHeight * scale,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: searching
            ? Row(
                key: const ValueKey('search'),
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('inbox-search-field'),
                      autofocus: true,
                      onChanged: onQuery,
                      style: TextStyle(
                          color: LuxeColors.text, fontSize: 14 * scale),
                      decoration: InputDecoration(
                        hintText: l10n.inboxSearchHint,
                        hintStyle: TextStyle(
                            color: LuxeColors.muted, fontSize: 14 * scale),
                        prefixIcon: Icon(BootstrapIcons.search,
                            color: LuxeColors.muted, size: 18 * scale),
                        prefixIconConstraints: BoxConstraints(
                            minWidth: 44 * scale, minHeight: 44 * scale),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12 * scale, vertical: 12 * scale),
                        isDense: true,
                        filled: true,
                        fillColor: LuxeColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14 * scale),
                          borderSide: BorderSide(color: LuxeColors.hair),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14 * scale),
                          borderSide: BorderSide(color: LuxeColors.hair),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.inboxCloseSearch,
                    onPressed: onSearchClose,
                    iconSize: 18 * scale,
                    icon: Icon(BootstrapIcons.x_lg, color: LuxeColors.text),
                  ),
                ],
              )
            : Row(
                key: const ValueKey('buttons'),
                children: [
                  _SquareButton(
                    scale: scale,
                    key: const Key('inbox-search'),
                    label: l10n.inboxSearch,
                    onTap: onSearchOpen,
                    child: const Icon(BootstrapIcons.search),
                  ),
                  const SizedBox(width: 8),
                  _SquareButton(
                    scale: scale,
                    key: const Key('inbox-unread'),
                    label: l10n.inboxUnreadOnly,
                    selected: unreadOnly,
                    onTap: onToggleUnread,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(unreadOnly
                            ? BootstrapIcons.envelope_exclamation
                            : BootstrapIcons.envelope),
                        const SizedBox(width: 5),
                        Text('$unreadCount'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SquareButton(
                      scale: scale,
                      key: const Key('inbox-add-friend'),
                      label: l10n.inboxAddFriend,
                      onTap: onAddFriend,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(BootstrapIcons.person_plus),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              l10n.inboxAddFriend,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: l10n.inboxCreate,
                    child: Semantics(
                      button: true,
                      label: l10n.inboxCreate,
                      excludeSemantics: true,
                      child: Material(
                        color: LuxeColors.text,
                        borderRadius: BorderRadius.circular(13 * scale),
                        child: InkWell(
                          key: const Key('inbox-create'),
                          borderRadius: BorderRadius.circular(13 * scale),
                          onTap: onCreate,
                          child: SizedBox(
                            width: inboxActionsHeight * scale,
                            height: inboxActionsHeight * scale,
                            child: Icon(BootstrapIcons.plus_lg,
                                color: LuxeColors.bg, size: 18 * scale),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.child,
    this.selected = false,
    this.scale = 1,
  });

  final String label;
  final VoidCallback onTap;
  final Widget child;
  final bool selected;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? LuxeColors.bg : LuxeColors.text;
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: Material(
          color: selected ? LuxeColors.text : LuxeColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13 * scale),
            side: BorderSide(color: LuxeColors.hair),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(13 * scale),
            onTap: onTap,
            child: Container(
              height: inboxActionsHeight * scale,
              constraints: BoxConstraints(minWidth: inboxActionsHeight * scale),
              padding: EdgeInsets.symmetric(horizontal: 12 * scale),
              alignment: Alignment.center,
              child: IconTheme(
                data: IconThemeData(color: fg, size: 18 * scale),
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w600,
                    fontSize: 13 * scale,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The dark card above the list that opens every private topic.
class PrivateTopicsCard extends StatelessWidget {
  const PrivateTopicsCard({
    super.key,
    required this.topics,
    required this.meId,
    required this.onTap,
  });

  final List<Conversation> topics;
  final int? meId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final unread = topics.fold<int>(0, (sum, t) => sum + t.unread);
    final latest = topics.isEmpty ? null : topics.first;
    final preview = latest == null
        ? l10n.inboxNoTopics
        : latest.lastMessage == null
            ? latest.title
            : '${latest.title}: ${latest.lastMessage!.body}';
    final members = <ChatUser>{
      for (final topic in topics) ...topic.others(meId),
    }.take(3).toList();
    final fg = LuxeColors.bg;

    return Semantics(
      button: true,
      label: unread > 0
          ? '${l10n.inboxPrivateTopics}, ${l10n.inboxUnreadLabel(unread)}'
          : l10n.inboxPrivateTopics,
      excludeSemantics: true,
      child: Material(
        color: LuxeColors.text,
        borderRadius: BorderRadius.circular(15),
        elevation: 4,
        shadowColor: LuxeColors.text.withValues(alpha: .4),
        child: InkWell(
          key: const Key('private-topics'),
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: Row(
              children: [
                if (members.isNotEmpty) ...[
                  SizedBox(
                    width: 24.0 + 15 * (members.length - 1),
                    height: 24,
                    child: Stack(
                      children: [
                        for (var i = 0; i < members.length; i++)
                          PositionedDirectional(
                            start: i * 15.0,
                            child: Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: LuxeColors.surface,
                                border: Border.all(
                                    color: LuxeColors.text, width: 1.5),
                              ),
                              child: Text(
                                members[i].initial,
                                style: TextStyle(
                                  color: LuxeColors.text,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(BootstrapIcons.lock_fill, size: 10, color: fg),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              l10n.inboxPrivateTopics,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: fg,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: fg.withValues(alpha: .7), fontSize: 9),
                      ),
                    ],
                  ),
                ),
                if (unread > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC8432F),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      '$unread',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  Icon(BootstrapIcons.chevron_right,
                      size: 17, color: fg.withValues(alpha: .7)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One conversation in the list: picture, name, last message, time, unread.
class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.meId,
    required this.onTap,
    this.onOptions,
    this.selected = false,
  });

  final Conversation conversation;
  final int? meId;
  final VoidCallback onTap;

  /// Opens the chat's options (hold, or right-click on desktop and web).
  final VoidCallback? onOptions;

  /// Highlighted as the chat open in the side pane.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final last = conversation.lastMessage;
    final unread = conversation.looksUnread;
    final String preview;
    if (last == null) {
      preview = l10n.inboxNoMessagesYet;
    } else {
      final text = last.deleted
          ? l10n.chatMessageDeleted
          : last.isSystem
              ? systemText(l10n, last, meId)
              : messageSnippet(l10n, last, mine: last.sender.id == meId);
      if (last.isSystem) {
        preview = text;
      } else if (last.sender.id == meId) {
        preview = l10n.inboxYouSaid(text);
      } else if (!conversation.isDirect) {
        preview = '${last.sender.username}: $text';
      } else {
        preview = text;
      }
    }
    // Muted chats keep a quiet grey badge.
    final badgeColor = conversation.muted ? LuxeColors.muted : LuxeColors.text;

    return Material(
      color: selected ? LuxeColors.surface2 : Colors.transparent,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        onLongPress: onOptions,
        onSecondaryTap: onOptions,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
          child: Row(
            children: [
              ConversationAvatar(
                conversation: conversation,
                meId: meId,
                size: 32,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            conversation.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: LuxeColors.text,
                              fontSize: 11,
                              fontWeight:
                                  unread ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (conversation.muted) ...[
                          const SizedBox(width: 4),
                          Semantics(
                            label: l10n.inboxMutedLabel,
                            child: Icon(BootstrapIcons.bell_slash,
                                key: const Key('conversation-muted'),
                                size: 10,
                                color: LuxeColors.muted),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: unread ? LuxeColors.text : LuxeColors.muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    relativeTakeTime(context, conversation.updatedAt),
                    style: TextStyle(color: LuxeColors.muted, fontSize: 9),
                  ),
                  const SizedBox(height: 3),
                  if (conversation.unread > 0)
                    Semantics(
                      label: l10n.inboxUnreadLabel(conversation.unread),
                      excludeSemantics: true,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          '${conversation.unread}',
                          style: TextStyle(
                            color: LuxeColors.bg,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else if (conversation.markedUnread)
                    // Marked unread by hand: a dot, no count.
                    Semantics(
                      label: l10n.chatMarkUnread,
                      excludeSemantics: true,
                      child: Container(
                        key: const Key('conversation-marked-unread'),
                        width: 9,
                        height: 9,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  else if (conversation.pinned)
                    Semantics(
                      label: l10n.inboxPinnedLabel,
                      child: Icon(BootstrapIcons.pin_angle_fill,
                          key: const Key('conversation-pinned'),
                          size: 11,
                          color: LuxeColors.muted),
                    )
                  else
                    const SizedBox(height: 13),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The full-height rail of group chats at the side of the home screen. It
/// slides in item by item when the Inbox tab opens and folds away sideways
/// (fading out) on the other tabs. The first item shows every chat.
class GroupRail extends StatefulWidget {
  const GroupRail({
    super.key,
    required this.visible,
    required this.groups,
    required this.onOpen,
    required this.onAll,
  });

  /// Shown on the Inbox tab only.
  final bool visible;
  final List<Conversation> groups;
  final ValueChanged<Conversation> onOpen;
  final VoidCallback onAll;

  @override
  State<GroupRail> createState() => _GroupRailState();
}

class _GroupRailState extends State<GroupRail>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  @override
  void initState() {
    super.initState();
    if (widget.visible) _enter.forward();
  }

  @override
  void didUpdateWidget(covariant GroupRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      _enter.forward(from: 0);
    } else if (!widget.visible && oldWidget.visible) {
      _enter.reverse();
    }
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  Widget _stagger(int index, Widget child) {
    final reduce = MediaQuery.of(context).disableAnimations;
    if (reduce) return child;
    final start = (index * .08).clamp(0.0, .6);
    final curve = CurvedAnimation(
      parent: _enter,
      curve: Interval(start, (start + .5).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: curve,
      child: child,
      builder: (context, child) => Opacity(
        opacity: curve.value,
        child: Transform.translate(
          offset: Offset(-20 * (1 - curve.value), 0),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reduce = MediaQuery.of(context).disableAnimations;
    final rail = Container(
      width: 45,
      decoration: BoxDecoration(
        border: BorderDirectional(end: BorderSide(color: LuxeColors.hair)),
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          0,
          15,
          0,
          110 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          _stagger(
            0,
            _RailItem(
              key: const Key('rail-all'),
              label: l10n.inboxAllChats,
              selected: true,
              onTap: widget.onAll,
              child: Icon(BootstrapIcons.chat_fill,
                  color: LuxeColors.bg, size: 14),
            ),
          ),
          if (widget.groups.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Divider(height: 1, color: LuxeColors.hair),
            ),
          for (var i = 0; i < widget.groups.length; i++)
            _stagger(
              i + 1,
              _RailItem(
                key: Key('rail-group-${widget.groups[i].id}'),
                label: widget.groups[i].title,
                badge: widget.groups[i].muted ? 0 : widget.groups[i].unread,
                onTap: () => widget.onOpen(widget.groups[i]),
                child: _RailGroupPicture(group: widget.groups[i]),
              ),
            ),
        ],
      ),
    );

    // Folds sideways: the width shrinks to nothing while the rail fades.
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: widget.visible ? 1 : 0),
      duration: reduce ? Duration.zero : const Duration(milliseconds: 340),
      curve: const Cubic(.32, .72, 0, 1),
      child: rail,
      builder: (context, t, child) => IgnorePointer(
        ignoring: !widget.visible,
        child: ClipRect(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: t,
            child: Opacity(opacity: t, child: child),
          ),
        ),
      ),
    );
  }
}

/// A group in the rail: its photo when it has one, else its first letter.
class _RailGroupPicture extends StatelessWidget {
  const _RailGroupPicture({required this.group});

  final Conversation group;

  @override
  Widget build(BuildContext context) {
    final letter = Text(
      group.title.isEmpty ? '?' : group.title[0].toUpperCase(),
      style: TextStyle(
        color: LuxeColors.text,
        fontWeight: FontWeight.w700,
        fontSize: 11,
      ),
    );
    final photo = group.photoUrl;
    if (photo == null || photo.isEmpty) return letter;
    return ClipOval(
      child: CachedNetworkImage(
        key: Key('rail-photo-${group.id}'),
        imageUrl: photo,
        cacheKey: stableImageKey(photo),
        width: 31,
        height: 31,
        fit: BoxFit.cover,
        placeholder: (_, __) => Center(child: letter),
        errorWidget: (_, __, ___) => Center(child: letter),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    super.key,
    required this.label,
    required this.onTap,
    required this.child,
    this.selected = false,
    this.badge = 0,
  });

  final String label;
  final VoidCallback onTap;
  final Widget child;
  final bool selected;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        excludeSemantics: true,
        child: SizedBox(
          height: 39,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // The pill at the edge: tall when selected, a dot when unread.
              PositionedDirectional(
                start: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 3,
                  height: selected ? 21 : (badge > 0 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: LuxeColors.text,
                    borderRadius: const BorderRadiusDirectional.horizontal(
                      end: Radius.circular(3),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 31,
                  height: 31,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? LuxeColors.text : LuxeColors.surface2,
                    borderRadius: BorderRadius.circular(selected ? 10 : 15),
                  ),
                  child: child,
                ),
              ),
              if (badge > 0)
                PositionedDirectional(
                  end: 1,
                  bottom: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC8432F),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: LuxeColors.bg, width: 1.5),
                    ),
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.title, this.body, this.action});

  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 8),
        child: Column(
          children: [
            Icon(BootstrapIcons.chat_square_text,
                size: 28, color: LuxeColors.muted),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: LuxeColors.text,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (body != null) ...[
              const SizedBox(height: 3),
              Text(
                body!,
                textAlign: TextAlign.center,
                style: TextStyle(color: LuxeColors.muted, fontSize: 9),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 6), action!],
          ],
        ),
      );
}
