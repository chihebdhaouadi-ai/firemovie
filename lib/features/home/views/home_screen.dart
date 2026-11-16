import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
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
    this.signedIn = true,
  });

  final ReviewRepository? reviews;
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
  String? _username;
  String? _avatarUrl;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.signedIn) unawaited(_loadNavData());
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.signedIn == widget.signedIn) return;
    // Signed in or out while Home is open: reload for the new state.
    _username = null;
    _avatarUrl = null;
    _unreadCount = 0;
    _exploring = false;
    if (widget.signedIn) unawaited(_loadNavData());
    context.read<HomeBloc>().add(const HomeStarted());
  }

  Future<void> _loadNavData() async {
    final profile = widget.profile;
    if (profile != null) {
      try {
        final me = await profile.fetchMe();
        if (!mounted) return;
        setState(() {
          _username = me.username;
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

  void _selectTab(HomeTab tab) => setState(() {
        _tab = tab;
        _exploring = false;
      });

  void _openExplore() {
    // Browsing reviews and takes is open to guests.
    setState(() => _exploring = true);
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
              if (_exploring) {
                return ExplorePage(
                  reviews: widget.reviews,
                  onBack: _closeExplore,
                );
              }
              return _HomeBody(
                state: loaded,
                reviews: widget.reviews,
                articles: widget.articles,
                signedIn: widget.signedIn,
                tab: _tab,
                onTabSelected: _selectTab,
                friendsHasUnread: _unreadCount > 0,
                notificationCount: _unreadCount,
                onOpenNotifications: _openNotifications,
                onAddFilm: () => openFind(context),
              );
            },
          ),
        ),
      ),
      // No SafeArea here: SageNavBar paints its own background down through the
      // bottom inset so nothing scrolls visibly underneath it.
      bottomNavigationBar: SageNavBar(
        leading: [
          SageNavEntry(
            item: const SageNavItem(
              icon: Icons.home_outlined,
              svgAsset: 'assets/svg/home.svg',
              label: '',
            ),
            semanticsLabel: l10n.homeTabYou,
            selected: !_exploring,
            onTap: () => _selectTab(HomeTab.you),
          ),
          SageNavEntry(
            item: const SageNavItem(icon: Icons.explore_outlined, label: ''),
            semanticsLabel: l10n.homeTabExplore,
            selected: _exploring,
            onTap: _openExplore,
          ),
        ],
        trailing: [
          SageNavEntry(
            item: const SageNavItem(
              icon: Icons.search,
              svgAsset: 'assets/svg/search.svg',
              label: '',
            ),
            semanticsLabel: l10n.homeQuickActionSearch,
            onTap: () => openFind(context),
          ),
          SageNavEntry(
            item: SageNavItem(
              icon: Icons.person_outline,
              label: '',
              avatar: avatarUrl == null || avatarUrl.isEmpty
                  ? null
                  : CachedNetworkImageProvider(avatarUrl),
              avatarInitial: _username,
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
            icon: Icons.explore_outlined,
            onTap: _openExplore,
          ),
          SageQuickAction(
            label: l10n.homeTabFilms,
            icon: Icons.movie_outlined,
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
    required this.onAddFilm,
    this.signedIn = true,
    this.reviews,
    this.articles,
  });

  final HomeLoaded state;
  final HomeTab tab;
  final ValueChanged<HomeTab> onTabSelected;
  final bool friendsHasUnread;
  final int notificationCount;
  final VoidCallback onOpenNotifications;
  final VoidCallback onAddFilm;
  final bool signedIn;
  final ReviewRepository? reviews;
  final ArticleRepository? articles;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final header = FilmsageHeaderDelegate(
      padding: EdgeInsets.fromLTRB(
        tokens.spaceLg,
        tokens.spaceLg,
        tokens.spaceLg,
        0,
      ),
      tabBar: HomeTabBar(
        selected: tab,
        onSelected: onTabSelected,
        friendsHasUnread: friendsHasUnread,
      ),
      tabBarVerticalPadding: tokens.spaceSm,
      notificationCount: notificationCount,
      onAddFilm: onAddFilm,
      onOpenNotifications: onOpenNotifications,
      addLabel: context.l10n.homeQuickActionAddFilm,
      notificationsLabel: context.l10n.notificationsTitle,
    );
    // Content blurs and narrows as it slides under the pinned header.
    final exitInset = header.minExtent;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
        child: RefreshIndicator(
          onRefresh: () => _refresh(context),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Pinned FilmSage header: fixed height, with the You / Friends /
              // Films tab bar inside it. It does not shrink on scroll.
              SliverPersistentHeader(
                pinned: true,
                delegate: header,
              ),
              // Keep the news ticker pinned directly below the tab bar.
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
                  tokens.spaceXl,
                  tokens.spaceLg,
                  tokens.spaceLg +
                      SageNavBar.height +
                      MediaQuery.paddingOf(context).bottom,
                ),
                sliver: SliverToBoxAdapter(
                  child: switch (tab) {
                    HomeTab.you => YouTab(
                        state: state,
                        exitInset: exitInset,
                        reviews: reviews,
                        signedIn: signedIn,
                      ),
                    HomeTab.friends => FriendsTab(
                        state: state,
                        exitInset: exitInset,
                        reviews: reviews,
                        signedIn: signedIn,
                      ),
                    HomeTab.films => FilmsTab(
                        state: state,
                        exitInset: exitInset,
                        reviews: reviews,
                        signedIn: signedIn,
                      ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
