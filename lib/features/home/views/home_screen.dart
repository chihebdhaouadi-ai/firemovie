import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/auth/auth_gate.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/game_parts.dart';
import '../../../core/widgets/sage_nav_bar/sage_nav_bar.dart';
import '../../../core/widgets/sage_nav_bar/sage_nav_models.dart';
import '../../film_reviews/data/review_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../../social/data/social_repository.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_screen_event.dart';
import '../bloc/home_screen_state.dart';
import '../data/home_models.dart';
import 'home_navigation.dart';
import 'explore_page.dart';
import 'home_tab.dart';
import 'tabs/films_tab.dart';
import 'tabs/friends_tab.dart';
import 'tabs/you_tab.dart';
import '../../articles/data/article_repository.dart';
import '../../news/views/news_ticker_section.dart';
import 'widgets/filmsage_header.dart';
import 'widgets/home_tab_bar.dart';
import '../../profile/views/profile_screen.dart';
import '../../social/views/notifications_screen.dart';
import '../../film_reviews/presentation/open_take.dart';
import '../../stories/data/friend_story.dart';
import '../../stories/data/story_repository.dart';
import '../../stories/views/story_viewer_screen.dart';
import '../../messaging/data/messaging_repository.dart';
import '../../messaging/data/messaging_models.dart';
import '../../messaging/views/chat_options.dart';
import '../../messaging/views/chat_screen.dart';
import '../../messaging/views/inbox_tab.dart';
import '../../../core/widgets/scroll_exit_effect.dart' show ExitInset;

/// How wide the home page may grow on the Inbox tab (desktop, tablets).
const _inboxMaxWidth = 1200.0;

/// The You tab's widest layout, two columns side by side.
const _youMaxWidth = 1200.0;

const _loadingState = HomeLoaded(
  sections: {
    HomeList.top5: SectionLoading(),
    HomeList.watched: SectionLoading(),
    HomeList.watchlist: SectionLoading(),
    HomeList.popular: SectionLoading(),
  },
);

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.reviews,
    this.profile,
    this.social,
    this.articles,
    this.stories,
    this.messaging,
    this.signedIn = true,
  });

  final ReviewRepository? reviews;

  /// Friends' story circles; none are shown without it.
  final StoryRepository? stories;

  /// Chats for the Inbox tab; the tab shows a placeholder without it.
  final MessagingRepository? messaging;
  final ProfileRepository? profile;
  final SocialRepository? social;
  final ArticleRepository? articles;

  /// False for guests: account-only sections show a sign-in prompt and no
  /// profile or notification requests are made.
  final bool signedIn;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeTab _tab = HomeTab.you;
  bool _exploring = false;

  /// Explore is kept alive once opened, so coming back to it (or to Home)
  /// shows the same content instead of loading it again.
  bool _exploreOpened = false;

  /// Tabs opened so far; they stay built (hidden) so switching back is
  /// instant and nothing reloads.
  final Set<HomeTab> _visitedTabs = {HomeTab.you};

  /// Bumped by pull-to-refresh: every section is rebuilt and loads again.
  int _refreshGeneration = 0;
  String? _avatarUrl;
  int _unreadCount = 0;
  int? _myId;
  int _unreadMessages = 0;
  List<Conversation> _groups = const [];
  List<FriendStory> _stories = const [];
  final SeenStories _seenStories = SeenStories();

  /// Hands the inbox's search / add friend row to the pinned bar under the
  /// tabs.
  final InboxActionsController _inboxActions = InboxActionsController();

  @override
  void initState() {
    super.initState();
    if (widget.signedIn) unawaited(_loadNavData());
  }

  @override
  void dispose() {
    _inboxActions.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.signedIn == widget.signedIn) return;
    // Signed in or out while Home is open: reload for the new state.
    _avatarUrl = null;
    _unreadCount = 0;
    _myId = null;
    _unreadMessages = 0;
    _stories = const [];
    _exploring = false;
    if (widget.signedIn) unawaited(_loadNavData());
    context.read<HomeBloc>().add(const HomeStarted());
  }

  /// Friends with something to show, the ones not yet watched first.
  Future<void> _loadStories() async {
    final repository = widget.stories;
    if (repository == null || !widget.signedIn) return;
    try {
      final stories = await repository.fetchFriendStories();
      await _seenStories.load(stories.map((story) => story.userId));
      if (!mounted) return;
      setState(() => _stories = _unseenFirst(stories));
    } on Exception {
      // No story circles this time.
    }
  }

  List<FriendStory> _unseenFirst(List<FriendStory> stories) => [
        ...stories.where((story) => !_seenStories.isSeen(story)),
        ...stories.where(_seenStories.isSeen),
      ];

  Future<void> _openStory(int index) async {
    final stories = _stories;
    if (index < 0 || index >= stories.length) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => StoryViewerScreen(
          stories: stories,
          initialIndex: index,
          onOpenItem: (item) =>
              openTakeById(context, item.takeId, reviews: widget.reviews),
          onWatched: (story) {
            unawaited(_seenStories.markSeen(story));
            if (mounted) setState(() {});
          },
        ),
      ),
    );
    if (mounted) setState(() => _stories = _unseenFirst(_stories));
  }

  Future<void> _loadUnreadMessages() async {
    final messaging = widget.messaging;
    if (messaging == null || !widget.signedIn) return;
    try {
      final chats = await messaging.conversations();
      if (!mounted) return;
      setState(() {
        _unreadMessages = chats.fold<int>(0, (sum, chat) => sum + chat.unread);
        _groups = chats.where((c) => c.kind == ConversationKind.group).toList();
      });
    } on Exception {
      // The Inbox tab keeps no unread dot.
    }
  }

  /// Opens a group chat from the side rail.
  Future<void> _openChat(Conversation chat) async {
    final messaging = widget.messaging;
    if (messaging == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ChatScreen(
          conversation: chat,
          repository: messaging,
          meId: _myId,
          loadFriends: friendLoader(widget.social),
        ),
      ),
    );
    if (mounted) unawaited(_loadUnreadMessages());
  }

  Future<void> _loadNavData() async {
    unawaited(_loadStories());
    unawaited(_loadUnreadMessages());
    final profile = widget.profile;
    if (profile != null) {
      try {
        final me = await profile.fetchMe();
        if (!mounted) return;
        setState(() {
          _myId = me.id;
          _avatarUrl = me.avatarUrl;
        });
      } on Exception {
        // The avatar keeps its icon fallback.
      }
    }
    final social = widget.social;
    if (social != null) {
      try {
        final page = await social.notifications();
        if (!mounted) return;
        setState(() => _unreadCount = page.unreadCount);
      } on Exception {
        // The friends tab keeps no unread dot.
      }
    }
  }

  void _selectTab(HomeTab tab) {
    setState(() {
      _tab = tab;
      _visitedTabs.add(tab);
      _exploring = false;
    });
    // The inbox needs to know who "me" is to place messages; fetch it again
    // if the first load did not get it.
    if (tab == HomeTab.friends && _myId == null && widget.signedIn) {
      unawaited(_loadNavData());
    }
  }

  void _openExplore() {
    // Browsing reviews and takes is open to guests.
    setState(() {
      _exploring = true;
      _exploreOpened = true;
    });
  }

  void _closeExplore() => setState(() => _exploring = false);

  void _openNotifications() {
    final social = widget.social;
    if (social == null) return;
    unawaited(requireAuth(
      context,
      reason: context.l10n.authReasonNotifications,
      action: () async {
        if (!mounted) return;
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => NotificationsScreen(
              repository: social,
              onOpenUser: (user) => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => ProfileScreen(
                    userId: user.id,
                    socialRepository: social,
                  ),
                ),
              ),
            ),
          ),
        );
        if (mounted) unawaited(_loadNavData());
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final avatarUrl = _avatarUrl;
    return Scaffold(
      backgroundColor: GameColors.background,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Group chats down the side of the whole page, on the Inbox
            // tab only; it folds away on the others.
            if (widget.messaging != null && widget.signedIn)
              GroupRail(
                visible: _tab == HomeTab.friends && !_exploring,
                groups: _groups,
                onOpen: _openChat,
                onAll: () => _selectTab(HomeTab.friends),
              ),
            Expanded(
              child: BlocListener<HomeBloc, HomeScreenState>(
                listenWhen: (previous, current) =>
                    _noticeId(previous) != _noticeId(current),
                listener: (context, state) {
                  if (state case HomeLoaded(notice: final notice?)) {
                    _showNotice(context, notice);
                  }
                },
                child: BlocBuilder<HomeBloc, HomeScreenState>(
                  builder: (context, state) {
                    final loaded = switch (state) {
                      HomeLoading() => _loadingState,
                      HomeLoaded loaded => loaded,
                    };
                    // Home and Explore both stay alive; only the visible one
                    // paints and ticks.
                    final home = _HomeBody(
                      inboxActions: _inboxActions,
                      visitedTabs: _visitedTabs,
                      refreshGeneration: _refreshGeneration,
                      onPullRefresh: () => setState(() => _refreshGeneration++),
                      state: loaded,
                      reviews: widget.reviews,
                      articles: widget.articles,
                      signedIn: widget.signedIn,
                      tab: _tab,
                      onTabSelected: _selectTab,
                      friendsHasUnread: _unreadMessages > 0,
                      notificationCount: _unreadCount,
                      messaging: widget.messaging,
                      social: widget.social,
                      meId: _myId,
                      onUnreadMessagesChanged: (count) {
                        if (count != _unreadMessages) {
                          setState(() => _unreadMessages = count);
                        }
                      },
                      onConversationsChanged: (chats) {
                        final groups = chats
                            .where((c) => c.kind == ConversationKind.group)
                            .toList();
                        if (!listEquals(groups, _groups)) {
                          setState(() => _groups = groups);
                        }
                      },
                      onOpenNotifications: _openNotifications,
                      stories: _stories,
                      isStorySeen: _seenStories.isSeen,
                      onOpenStory: _openStory,
                      onRefreshStories: _loadNavData,
                    );
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        _KeptAlive(visible: !_exploring, child: home),
                        if (_exploreOpened)
                          _KeptAlive(
                            visible: _exploring,
                            child: ExplorePage(
                              reviews: widget.reviews,
                              onBack: _closeExplore,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      // No SafeArea here: SageNavBar paints its own background down through the
      // bottom inset so nothing scrolls visibly underneath it.
      bottomNavigationBar: SageNavBar(
        leading: [
          SageNavEntry(
            item: const SageNavItem(
              icon: BootstrapIcons.house,
              label: '',
            ),
            semanticsLabel: l10n.homeTabYou,
            selected: !_exploring,
            onTap: () => _selectTab(HomeTab.you),
          ),
          SageNavEntry(
            item: const SageNavItem(
              icon: BootstrapIcons.compass,
              label: '',
            ),
            semanticsLabel: l10n.homeTabExplore,
            selected: _exploring,
            onTap: _openExplore,
          ),
        ],
        trailing: [
          SageNavEntry(
            item: const SageNavItem(
              icon: BootstrapIcons.search,
              label: '',
            ),
            semanticsLabel: l10n.homeQuickActionSearch,
            onTap: () => openFind(context),
          ),
          SageNavEntry(
            item: SageNavItem(
              icon: BootstrapIcons.person,
              label: '',
              avatar: avatarUrl == null || avatarUrl.isEmpty
                  ? null
                  : CachedNetworkImageProvider(avatarUrl),
              svgAsset: 'assets/svg/profile.svg',
            ),
            semanticsLabel: l10n.homeOpenProfile,
            onTap: () => openProfile(context),
          ),
        ],
        centerSemanticsLabel: l10n.homeQuickActionsLabel,
        closeLabel: l10n.sageNavCloseMenu,
        centerActions: [
          SageQuickAction(
            label: l10n.homeQuickActionAddFilm,
            svgAsset: 'assets/svg/add.svg',
            onTap: () => openFind(context),
          ),
          SageQuickAction(
            label: l10n.homeTabExplore,
            icon: BootstrapIcons.compass,
            onTap: _openExplore,
          ),
          SageQuickAction(
            label: l10n.homeCollectionsTitle,
            icon: BootstrapIcons.film,
            onTap: () => _selectTab(HomeTab.films),
          ),
        ],
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.state,
    required this.tab,
    required this.onTabSelected,
    required this.friendsHasUnread,
    required this.notificationCount,
    required this.onOpenNotifications,
    this.signedIn = true,
    this.reviews,
    this.articles,
    this.stories = const [],
    this.isStorySeen,
    this.onOpenStory,
    this.onRefreshStories,
    this.messaging,
    this.social,
    this.meId,
    this.onUnreadMessagesChanged,
    this.onConversationsChanged,
    this.visitedTabs = const {HomeTab.you},
    this.refreshGeneration = 0,
    this.onPullRefresh,
    this.inboxActions,
  });

  /// The inbox's action row, pinned under the tabs on the Inbox tab.
  final InboxActionsController? inboxActions;

  /// Tabs to keep built (the hidden ones stay offstage).
  final Set<HomeTab> visitedTabs;

  /// Changes on pull-to-refresh, rebuilding every section so it reloads.
  final int refreshGeneration;
  final VoidCallback? onPullRefresh;

  final HomeLoaded state;
  final HomeTab tab;
  final ValueChanged<HomeTab> onTabSelected;
  final bool friendsHasUnread;
  final int notificationCount;
  final VoidCallback onOpenNotifications;
  final bool signedIn;
  final ReviewRepository? reviews;
  final ArticleRepository? articles;
  final List<FriendStory> stories;
  final bool Function(FriendStory story)? isStorySeen;
  final ValueChanged<int>? onOpenStory;
  final Future<void> Function()? onRefreshStories;
  final MessagingRepository? messaging;
  final SocialRepository? social;
  final int? meId;
  final ValueChanged<int>? onUnreadMessagesChanged;
  final ValueChanged<List<Conversation>>? onConversationsChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final messaging = this.messaging;
    final header = FilmsageHeaderDelegate(
      padding: EdgeInsets.fromLTRB(
        tokens.spaceLg,
        tokens.spaceLg,
        tokens.spaceLg,
        0,
      ),
      // On a wide window the tab bar keeps a phone-like width in the middle
      // rather than stretching across the page.
      tabBarBuilder: (progress) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
          child: HomeTabBar(
            selected: tab,
            onSelected: onTabSelected,
            friendsHasUnread: friendsHasUnread,
            collapse: progress,
          ),
        ),
      ),
      tabBarVerticalPadding: tokens.spaceSm,
      notificationCount: notificationCount,
      onOpenNotifications: onOpenNotifications,
      notificationsLabel: context.l10n.notificationsTitle,
      stories: stories,
      isStorySeen: isStorySeen,
      onOpenStory: onOpenStory,
    );
    // Content starts to fade and narrow 20 px below the You / Friends /
    // Films bar, so the effect is already under way as it reaches the bar.
    final inboxActions = this.inboxActions;
    final pinInboxActions = tab == HomeTab.friends &&
        messaging != null &&
        signedIn &&
        inboxActions != null;
    final inboxBar = inboxActions == null
        ? null
        : InboxActionsBarDelegate(
            controller: inboxActions,
            verticalPadding: tokens.spaceSm,
            horizontalPadding: tokens.spaceLg,
            background: GameColors.background,
            shrinkStart: header.maxExtent - header.minExtent,
          );
    // On the Inbox the pinned row is the edge: chats disappear under its
    // bottom border. Elsewhere content fades a little below the tab bar.
    double exitInset(double pixels) {
      final tabBarBottom = header.tabBarBottomAt(pixels);
      if (!pinInboxActions || inboxBar == null) return tabBarBottom + 20;
      return tabBarBottom + header.tabBarVerticalPadding + inboxBar.maxExtent;
    }

    return Center(
      child: ConstrainedBox(
        // The inbox (list and chat panes) and the You tab (two columns) can
        // use a wide window; the other tabs keep a readable column.
        constraints: BoxConstraints(
          maxWidth: switch (tab) {
            HomeTab.friends when messaging != null => _inboxMaxWidth,
            HomeTab.you => _youMaxWidth,
            _ => tokens.maxContentWidth,
          },
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            onPullRefresh?.call();
            final reloadStories = onRefreshStories;
            await Future.wait([
              _refresh(context),
              if (reloadStories != null) reloadStories(),
            ]);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Pinned FilmSage header with the You / Friends / Films tab bar
              // inside it. The wordmark and tab bar shrink a little on scroll.
              SliverPersistentHeader(
                pinned: true,
                delegate: header,
              ),
              // The inbox's search / unread / add friend / + row stays
              // directly under the tabs while the chats scroll.
              if (pinInboxActions && inboxBar != null)
                SliverPersistentHeader(pinned: true, delegate: inboxBar),
              // Keep the news ticker pinned directly below the tab bar.
              // Hidden for now; flip [_showNewsTicker] to bring it back.
              if (_showNewsTicker)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PinnedNewsTickerDelegate(
                    height: 56 + tokens.spaceMd,
                    child: ColoredBox(
                      color: const Color.fromARGB(0, 18, 18, 20),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          tokens.spaceLg,
                          tokens.spaceMd,
                          tokens.spaceLg,
                          0,
                        ),
                        child: NewsTickerSection(repository: articles),
                      ),
                    ),
                  ),
                ),
              SliverPadding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  tokens.spaceLg,
                  pinInboxActions ? tokens.spaceSm : tokens.spaceXl,
                  tokens.spaceLg,
                  tokens.spaceLg +
                      SageNavBar.height +
                      MediaQuery.paddingOf(context).bottom,
                ),
                sliver: SliverToBoxAdapter(
                  // Every tab opened so far stays built underneath, so
                  // coming back to it shows the same data without loading.
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final t in HomeTab.values)
                        if (visitedTabs.contains(t) || t == tab)
                          _KeptAlive(
                            visible: t == tab,
                            inFlow: true,
                            child: KeyedSubtree(
                              key: ValueKey('tab-${t.name}-$refreshGeneration'),
                              child: _tabBody(t, exitInset, messaging),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabBody(
    HomeTab tab,
    ExitInset exitInset,
    MessagingRepository? messaging,
  ) {
    return switch (tab) {
      HomeTab.you => YouTab(
          state: state,
          exitInset: exitInset,
          reviews: reviews,
          signedIn: signedIn,
        ),
      HomeTab.friends => messaging == null
          ? FriendsTab(exitInset: exitInset)
          : InboxTab(
              exitInset: exitInset,
              repository: messaging,
              social: social,
              meId: meId,
              signedIn: signedIn,
              active: this.tab == HomeTab.friends,
              onUnreadChanged: onUnreadMessagesChanged,
              onConversationsChanged: onConversationsChanged,
              actionsController: inboxActions,
            ),
      HomeTab.films => FilmsTab(
          state: state,
          exitInset: exitInset,
          reviews: reviews,
          signedIn: signedIn,
        ),
    };
  }
}

/// Keeps [child] alive while hidden: hidden content is not painted, does not
/// take taps, and its animations pause. With [inFlow] (inside a column) a
/// hidden child also takes no space.
class _KeptAlive extends StatelessWidget {
  const _KeptAlive({
    required this.visible,
    required this.child,
    this.inFlow = false,
  });

  final bool visible;
  final bool inFlow;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final kept = TickerMode(enabled: visible, child: child);
    if (inFlow) return Offstage(offstage: !visible, child: kept);
    return Visibility(
      visible: visible,
      maintainState: true,
      maintainAnimation: false,
      child: kept,
    );
  }
}

/// Whether the FilmSage News ticker shows under the home tabs.
const _showNewsTicker = false;

class _PinnedNewsTickerDelegate extends SliverPersistentHeaderDelegate {
  const _PinnedNewsTickerDelegate({
    required this.height,
    required this.child,
  });

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) =>
      // The child must fill the declared extent. NewsTickerSection collapses to
      // zero height while loading or when there is no article, and a pinned
      // header whose child is shorter than its extent throws in layout, which
      // freezes every later frame.
      SizedBox(height: height, child: child);

  @override
  bool shouldRebuild(covariant _PinnedNewsTickerDelegate oldDelegate) =>
      oldDelegate.height != height || oldDelegate.child != child;
}

int? _noticeId(HomeScreenState state) => switch (state) {
      HomeLoaded(:final notice) => notice?.id,
      HomeLoading() => null,
    };

Future<void> _refresh(BuildContext context) {
  final bloc = context.read<HomeBloc>();
  final done = Completer<void>();
  bloc.add(HomeRefreshRequested(done: done));
  return done.future;
}

void _showNotice(BuildContext context, HomeNotice notice) {
  final l10n = context.l10n;
  final bloc = context.read<HomeBloc>();

  final message = switch (notice) {
    FilmRemovedNotice(:final film) =>
      l10n.homeRemovedSnackbar(film.displayTitle),
    Top5FullNotice() => l10n.homeTop5FullSnackbar,
    ActionFailedNotice() => l10n.homeGenericErrorSnackbar,
  };

  final action = switch (notice) {
    FilmRemovedNotice(:final list, :final film, :final index) => SnackBarAction(
        label: l10n.homeUndo,
        onPressed: () => bloc.add(HomeFilmRestored(list, film, index)),
      ),
    _ => null,
  };

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), action: action));
}
