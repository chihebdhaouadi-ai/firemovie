import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/auth/auth_gate.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/luxe_palette.dart';
import '../../../core/widgets/pill_tabs.dart';
import '../../../l10n/app_localizations.dart';
import '../../film_reviews/data/api_review_repository.dart';
import '../../film_reviews/data/reactions_repository.dart';
import '../../film_reviews/data/review_repository.dart';
import '../../film_reviews/domain/film_reaction.dart';
import '../../film_reviews/domain/movie_review_summary.dart';
import '../../film_reviews/domain/take.dart';
import '../../film_reviews/domain/take_skin.dart';
import '../../film_reviews/domain/take_tag.dart';
import '../../film_reviews/presentation/state/movie_reviews_cubit.dart';
import '../../film_reviews/presentation/state/movie_reviews_state.dart';
import '../../film_reviews/presentation/widgets/feeling_chip.dart';
import '../../film_reviews/presentation/widgets/feeling_motion.dart';
import '../../film_reviews/presentation/widgets/people_takes.dart';
import '../../film_reviews/presentation/widgets/take_film_cover.dart';
import '../../home/data/home_models.dart' show Film;
import '../../film_reviews/presentation/widgets/spoiler_shield.dart';
import '../../film_reviews/presentation/widgets/take_skin_background.dart';
import '../../overview/views/widgets/friend_activity.dart';
import '../../social/data/social_repository.dart';
import '../../social/views/movie_suggestion_screen.dart';
import '../data/api_lists_repository.dart';
import '../data/find_repository.dart';
import '../data/lists_repository.dart';
import '../../person/views/person_screen.dart';
import '../data/movie.dart';
import 'widgets/streaming_provider_logo.dart';
import 'widgets/trailer_player_dialog.dart';

// Same palette as Home (LuxeColors): matte surfaces, hairlines, one blue accent.
Color get _pageBackground => LuxeColors.bg;
Color get _pageCard => LuxeColors.surface;
Color get _pageChip => LuxeColors.surface2;
Color get _pageBlue => LuxeColors.accent;
Color get _pageMuted => LuxeColors.muted;
Color get _pageLine => LuxeColors.hair;

/// Page text: white in dark mode, near-black ink in light mode.
Color get _pageInk => themed(Colors.white, LuxeColors.text);

/// Secondary page text: white70 in dark mode, warm dark grey in light mode.
Color get _pageInkSoft => themed(Colors.white70, const Color(0xFF4A453C));
const _cardRadius = 28.0;

/// Longest take the backend accepts (`MAX_TAKE_LENGTH`).
const _maxTakeLength = 1500;

/// The film page: hero with trailer, overview (lists, suggest, feelings,
/// audience, friends, takes), cast & crew, and where to watch.
class FilmDetailScreen extends StatefulWidget {
  const FilmDetailScreen({
    super.key,
    required this.movie,
    this.repository,
    this.heroTag,
    this.footer,
    this.listsRepository,
    this.reviewRepository,
    this.reactionsRepository,
    this.socialRepository,
  });

  final Movie movie;
  final FindRepository? repository;
  final Object? heroTag;
  final Widget? footer;
  final ListsRepository? listsRepository;
  final ReviewRepository? reviewRepository;
  final ReactionsRepository? reactionsRepository;
  final SocialRepository? socialRepository;

  @override
  State<FilmDetailScreen> createState() => _FilmDetailScreenState();
}

class _FilmDetailScreenState extends State<FilmDetailScreen> {
  late final FindRepository _repository;
  late final ListsRepository _lists;
  late final MovieReviewsCubit _reviews;
  Movie? _detail;
  late final Future<void> _detailLoad;
  List<String> _stills = const [];
  int _selectedTab = 0;
  bool _overviewExpanded = false;

  final _takesKey = GlobalKey();
  bool _shareButtonVisible = false;
  bool _shareCheckPending = false;

  /// Feelings tapped but not yet saved; saves run one at a time.
  List<FilmReaction>? _draftFeelings;
  bool _savingFeelings = false;

  /// The viewer's lists for this film once changed here; null means "use the
  /// film's own membership flags".
  Set<String>? _inLists;
  final Set<FilmListId> _listBusy = {};

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? FindRepository();
    _lists = widget.listsRepository ?? ApiListsRepository();
    _reviews = MovieReviewsCubit(
      filmId: widget.movie.id,
      repository: widget.reviewRepository ?? ApiReviewRepository(),
      reactions: widget.reactionsRepository,
    )..load();
    _detailLoad = _load();
    _loadStills();
  }

  @override
  void dispose() {
    _reviews.close();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final detail = await _repository.fetchDetail(widget.movie.id);
      if (mounted) setState(() => _detail = detail);
    } catch (error, stackTrace) {
      debugPrint('Could not load film details: $error\n$stackTrace');
    }
  }

  Future<void> _loadStills() async {
    try {
      final stills = await _repository.fetchStills(widget.movie.id);
      if (mounted) setState(() => _stills = stills);
    } catch (error, stackTrace) {
      debugPrint('Could not load film stills: $error\n$stackTrace');
    }
  }

  static const _listKeys = {
    FilmListId.watched: 'watched',
    FilmListId.watchlist: 'watchlist',
  };

  Set<String> _membership(Movie movie) => _inLists ?? movie.inLists.toSet();

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Adds or removes the film from Watched / Watchlist. The button changes at
  /// once and rolls back if the server refuses.
  Future<void> _toggleList(Movie movie, FilmListId list) async {
    if (_listBusy.contains(list)) return;
    final l10n = context.l10n;
    await requireAuth(
      context,
      reason: l10n.authReasonFilm,
      action: () async {
        final key = _listKeys[list]!;
        final before = _membership(movie);
        final adding = !before.contains(key);
        setState(() {
          _listBusy.add(list);
          _inLists = {...before}..toggle(key, adding);
        });
        try {
          if (adding) {
            final entry = await _lists.add(list, movie.id);
            if (entry.removedFromWatchlist && mounted) {
              setState(() => _inLists = {..._inLists!}..remove('watchlist'));
            }
          } else {
            await _lists.remove(list, movie.id);
          }
        } catch (_) {
          if (!mounted) return;
          setState(() => _inLists = before);
          _snack(l10n.filmListFailed);
        } finally {
          if (mounted) setState(() => _listBusy.remove(list));
        }
      },
    );
  }

  Future<void> _openSuggest(Movie movie) async {
    final l10n = context.l10n;
    await requireAuth(
      context,
      reason: l10n.authReasonFilm,
      action: () async {
        final sent = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (_) => MovieSuggestionScreen(
              socialRepository: widget.socialRepository ?? SocialRepository(),
              findRepository: _repository,
              initialMovie: movie,
            ),
          ),
        );
        if (sent == true && mounted) _snack(l10n.suggestionSent);
      },
    );
  }

  /// Opens the feelings sheet. Picks show on the card behind it straight
  /// away; they are saved once, when the sheet closes, if they changed.
  Future<void> _openFeelingsSheet(List<FilmReaction> saved) async {
    final start = List.of(_draftFeelings ?? saved);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: _pageCard,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 560),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(_cardRadius)),
      ),
      builder: (_) => _FeelingsSheet(
        initial: start,
        onChanged: (picked) => setState(() => _draftFeelings = picked),
      ),
    );
    if (!mounted) return;
    final draft = _draftFeelings;
    if (draft == null) return;
    if (listEquals(draft, saved) && !_savingFeelings) {
      setState(() => _draftFeelings = null);
      return;
    }
    await _saveFeelings();
  }

  Future<void> _saveFeelings() async {
    if (_savingFeelings) return;
    _savingFeelings = true;
    try {
      while (mounted && _draftFeelings != null) {
        final sending = _draftFeelings!;
        final saved = await _reviews.setFeelings(sending);
        if (!mounted) return;
        if (!saved) {
          setState(() => _draftFeelings = null);
          _snack(context.l10n.reviewReactionFailed);
          return;
        }
        if (listEquals(_draftFeelings, sending)) {
          setState(() => _draftFeelings = null);
        }
      }
    } finally {
      _savingFeelings = false;
    }
  }

  Future<void> _openTakeComposer() async {
    final l10n = context.l10n;
    final outcome = await showModalBottomSheet<ShareTakeOutcome>(
      context: context,
      backgroundColor: _pageCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(_cardRadius)),
      ),
      builder: (_) => _TakeComposerSheet(onShare: _reviews.shareTakeOutcome),
    );
    if (outcome == null || !mounted) return;
    _snack(switch (outcome) {
      ShareTakeOutcome.shared => l10n.reviewSharedThanks,
      ShareTakeOutcome.alreadyShared => l10n.reviewAlreadyShared,
      ShareTakeOutcome.needsFeeling => l10n.reviewNeedsFeeling,
      ShareTakeOutcome.failed => l10n.reviewTakeFailed,
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final movie = _detail ?? widget.movie;

    return BlocProvider.value(
      value: _reviews,
      child: Scaffold(
        backgroundColor: _pageBackground,
        body: BlocBuilder<MovieReviewsCubit, MovieReviewsState>(
          builder: (context, state) {
            final canShare = _selectedTab == 0 && _canShare(state);
            _scheduleShareCheck();
            return Stack(
              children: [
                NotificationListener<ScrollNotification>(
                  onNotification: (_) {
                    _scheduleShareCheck();
                    return false;
                  },
                  child: _page(context, movie, l10n, canShare),
                ),
                if (canShare)
                  PositionedDirectional(
                    start: 0,
                    end: 0,
                    bottom: 0,
                    child: _FloatingShareButton(
                      visible: _shareButtonVisible,
                      label: l10n.filmShareYourTake,
                      onTap: _openTakeComposer,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _page(
    BuildContext context,
    Movie movie,
    AppLocalizations l10n,
    bool canShare,
  ) {
    final labels = [
      l10n.findDetailsOverview.toUpperCase(),
      '${l10n.overviewTabCast} & ${l10n.overviewTabCrew}',
      l10n.overviewWhereToWatch.toUpperCase(),
    ];

    return CustomScrollView(
      slivers: [
        _hero(context, movie, l10n),
        // The tabs stick under the collapsed header and shrink a little.
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabsHeader(
            labels: labels,
            selected: _selectedTab,
            onSelected: (index) => setState(() => _selectedTab = index),
            maxWidth: context.tokens.maxContentWidth,
          ),
        ),
        SliverList.list(
          children: [
            if (_selectedTab == 0) _overview(context, movie, l10n),
            if (_selectedTab == 1) _castAndCrew(context, movie, l10n),
            if (_selectedTab == 2) _watchProviders(context, movie, l10n),
            if (_selectedTab == 0 && widget.footer != null)
              _constrained(
                context,
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: widget.footer!,
                ),
              ),
            // Room for the floating button so it never covers the last take.
            SizedBox(height: canShare ? 110 : 40),
          ],
        ),
      ],
    );
  }

  /// Backdrop with the trailer button. It collapses into a slim bar as the
  /// page scrolls; the back arrow stays, and the title fades in once small.
  Widget _hero(BuildContext context, Movie movie, AppLocalizations l10n) {
    final backdrop = _stills.isNotEmpty
        ? _stills.first
        : movie.backdropUrl ?? movie.posterUrl;
    const expanded = 260.0;

    return SliverAppBar(
      key: const ValueKey('film-detail-header'),
      pinned: true,
      expandedHeight: expanded,
      backgroundColor: _pageBackground,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: const EdgeInsetsDirectional.only(start: 8),
        child: Center(
          child: Material(
            color: Colors.black.withValues(alpha: .35),
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: l10n.overviewBack,
              icon: Icon(
                BootstrapIcons.arrow_left,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
        ),
      ),
      leadingWidth: 64,
      flexibleSpace: LayoutBuilder(
        builder: (context, box) {
          final top = MediaQuery.paddingOf(context).top;
          final collapsed = kToolbarHeight + top;
          // 0 when fully open, 1 once collapsed into the bar.
          final t =
              ((expanded + top - box.maxHeight) / (expanded - kToolbarHeight))
                  .clamp(0.0, 1.0);
          return Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                opacity: 1 - t,
                child: Hero(
                  tag: widget.heroTag ?? 'detail-${movie.id}',
                  child: _coverImage(backdrop),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      // Light mode fades the top shade out as the bar
                      // collapses, so the pinned bar is plain paper.
                      themed(
                        const Color(0x66000000),
                        Color.fromRGBO(0, 0, 0, .4 * (1 - t)),
                      ),
                      // Transparent paper, not transparent black, so the
                      // fade into the page has no grey band.
                      themed(const Color(0x00000000), const Color(0x00F2EEE6)),
                      _pageBackground
                    ],
                    stops: [0, .45, 1],
                  ),
                ),
              ),
              if (t < .6)
                Center(
                  child: Opacity(
                    opacity: (1 - t / .6).clamp(0.0, 1.0),
                    child: IconButton(
                      tooltip: l10n.overviewPlayTrailer,
                      iconSize: 60,
                      onPressed: () => _openTrailer(movie),
                      icon: const Icon(
                        BootstrapIcons.play_circle,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              if (t > .7)
                PositionedDirectional(
                  start: 72,
                  end: 20,
                  top: top,
                  height: collapsed - top,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: ((t - .7) / .3).clamp(0.0, 1.0),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          movie.displayTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _pageInk,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Plays the trailer in the in-app pop-up player. Without a known YouTube
  /// video, falls back to the trailer link or a YouTube search in the browser.
  Future<void> _openTrailer(Movie shown) async {
    // The trailer id arrives with the details; wait if they are still loading.
    await _detailLoad;
    if (!mounted) return;
    final movie = _detail ?? shown;
    final videoId = movie.trailerYoutubeId;
    if (videoId != null) {
      await TrailerPlayerDialog.show(
        context,
        videoId: videoId,
        title: movie.displayTitle,
      );
      return;
    }
    final direct = movie.trailerUrl;
    final query = [
      movie.displayTitle,
      if (movie.year != null) '${movie.year}',
      'official trailer',
    ].join(' ');
    final uri = direct != null
        ? Uri.parse(direct)
        : Uri.https('www.youtube.com', '/results', {'search_query': query});
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.overviewTrailerUnavailable)),
      );
    }
  }

  Widget _coverImage(String? url) {
    if (url == null || url.isEmpty) return _backdropPlaceholder();
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => _backdropPlaceholder(),
      errorWidget: (_, __, ___) => _backdropPlaceholder(),
    );
  }

  Widget _backdropPlaceholder() {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3A3F4D), Color(0xFF1A1C22)],
        ),
      ),
    );
  }

  Widget _overview(BuildContext context, Movie movie, AppLocalizations l10n) {
    final membership = _membership(movie);
    final watched = membership.contains('watched');
    final watchlist = membership.contains('watchlist');

    return _constrained(
      context,
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: BlocBuilder<MovieReviewsCubit, MovieReviewsState>(
          builder: (context, state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _movieSummary(context, movie, l10n),
              const SizedBox(height: 16),
              Row(
                children: [
                  _ActionPill(
                    icon:
                        watched ? BootstrapIcons.eye_fill : BootstrapIcons.eye,
                    label: l10n.homeWatchedTitle,
                    active: watched,
                    busy: _listBusy.contains(FilmListId.watched),
                    onTap: () => _toggleList(movie, FilmListId.watched),
                  ),
                  const SizedBox(width: 8),
                  _ActionPill(
                    icon: watchlist
                        ? BootstrapIcons.bookmark_fill
                        : BootstrapIcons.bookmark,
                    label: l10n.homeWatchlistTitle,
                    active: watchlist,
                    busy: _listBusy.contains(FilmListId.watchlist),
                    onTap: () => _toggleList(movie, FilmListId.watchlist),
                  ),
                  const SizedBox(width: 8),
                  _ActionPill(
                    icon: BootstrapIcons.send,
                    label: l10n.filmSuggest,
                    onTap: () => _openSuggest(movie),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              _feelings(context, l10n, state.summary),
              const SizedBox(height: 26),
              _audience(context, l10n, state.summary),
              const SizedBox(height: 26),
              _section(
                context,
                l10n.overviewActivityTitle,
                FriendActivity(
                  movieId: movie.id,
                  repository: widget.reviewRepository,
                  embedded: true,
                ),
              ),
              const SizedBox(height: 26),
              _takesSection(context, l10n, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _movieSummary(
    BuildContext context,
    Movie movie,
    AppLocalizations l10n,
  ) {
    final runtime = movie.runtime;
    final overview = movie.overview?.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _poster(movie),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    movie.displayTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: _pageInk,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (movie.year != null) _metadata(movie.year.toString()),
                  if (runtime != null)
                    _metadata(l10n.findDetailsRuntime(runtime)),
                  if (movie.voteAverage != null)
                    _metadata(
                      l10n.findDetailsVote(
                        movie.voteAverage!.toStringAsFixed(1),
                      ),
                    ),
                ],
              ),
              if (movie.genres.isNotEmpty) ...[
                const SizedBox(height: 5),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final genre in movie.genres)
                      Text(
                        genre,
                        style: TextStyle(
                          color: _pageBlue,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
              if (movie.director != null) ...[
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${l10n.findDirectedBy} ',
                        style: TextStyle(color: _pageInkSoft),
                      ),
                      TextSpan(
                        text: movie.director,
                        style: TextStyle(
                          color: _pageInk,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
              const SizedBox(height: 7),
              Text(
                overview == null || overview.isEmpty
                    ? l10n.homeComingSoon
                    : overview,
                maxLines: _overviewExpanded ? null : 4,
                overflow: _overviewExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: TextStyle(
                  color: _pageInkSoft,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
              if (overview != null && overview.length > 180)
                TextButton(
                  onPressed: () => setState(
                    () => _overviewExpanded = !_overviewExpanded,
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    _overviewExpanded
                        ? l10n.overviewShowLess
                        : l10n.overviewShowMore,
                    style: TextStyle(color: _pageBlue, fontSize: 11),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _poster(Movie movie) {
    final url = movie.posterUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 100,
        height: 148,
        child: url == null || url.isEmpty
            ? _posterPlaceholder(movie)
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) => _posterPlaceholder(movie),
                errorWidget: (_, __, ___) => _posterPlaceholder(movie),
              ),
      ),
    );
  }

  Widget _posterPlaceholder(Movie movie) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2B2E38), Color(0xFF542B32)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            movie.displayTitle.toUpperCase(),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _metadata(String value) {
    return Text(
      value,
      style: TextStyle(color: _pageInkSoft, fontSize: 11),
    );
  }

  Widget _feelings(
    BuildContext context,
    AppLocalizations l10n,
    AsyncView<MovieReviewSummary> summary,
  ) {
    final saved = switch (summary) {
      AsyncReady(:final value) => value.feelings,
      _ => const <FilmReaction>[],
    };
    final feelings = _draftFeelings ?? saved;
    final ready = summary is AsyncReady<MovieReviewSummary>;

    return _section(
      context,
      l10n.reviewReactionTitle,
      onTap: ready ? () => _openFeelingsSheet(saved) : null,
      trailing: ready && feelings.isNotEmpty
          ? _SectionLink(
              icon: BootstrapIcons.pencil,
              label: l10n.reviewReactionChange,
              onTap: () => _openFeelingsSheet(saved),
            )
          : null,
      switch (summary) {
        AsyncLoading() => LinearProgressIndicator(
            color: _pageBlue,
            backgroundColor: _pageChip,
          ),
        AsyncFailed() => _RetryRow(
            message: l10n.reviewSummaryFailed,
            label: l10n.reviewRetry,
            onRetry: _reviews.load,
          ),
        AsyncReady() when feelings.isEmpty =>
          FeelingsEmptyInvite(label: l10n.filmFeelingsEmpty),
        // Like the audience bar: one feeling fills the row, two or three
        // share it equally.
        AsyncReady() => IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < feelings.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: FeelingChip(
                      feeling: feelings[i],
                      selected: true,
                      animate: true,
                      fill: true,
                      compact: feelings.length == 3,
                    ),
                  ),
                ],
              ],
            ),
          ),
      },
    );
  }

  Widget _audience(
    BuildContext context,
    AppLocalizations l10n,
    AsyncView<MovieReviewSummary> summary,
  ) {
    if (summary is! AsyncReady<MovieReviewSummary>) {
      return const SizedBox.shrink();
    }
    final value = summary.value;
    final hasCounts = value.allCounts.any((item) => item.count > 0);

    return _section(
      context,
      l10n.filmAudienceTitle,
      trailingText:
          value.total == 0 ? null : l10n.filmAudiencePeople(value.total),
      value.total == 0 || !hasCounts
          ? Text(
              l10n.filmAudienceEmpty,
              style: TextStyle(color: _pageMuted, fontSize: 14),
            )
          : AudienceBar(counts: value.allCounts),
    );
  }

  /// One review per person: once the viewer has shared theirs, sharing goes.
  static bool _canShare(MovieReviewsState state) {
    final takes = state.takes;
    return takes is AsyncReady<List<Take>> &&
        !takes.value.any((take) => take.isMine && take.tag == TakeTag.review);
  }

  /// Shows the floating "Share your take" button while any part of "What
  /// people said" is on screen, and hides it once the section scrolls away.
  /// Checks after the frame: scroll notifications can arrive mid-layout,
  /// when the section's size cannot be read yet.
  void _scheduleShareCheck() {
    if (_shareCheckPending) return;
    _shareCheckPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _shareCheckPending = false;
      if (mounted) _updateShareButton();
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _updateShareButton() {
    final box = _takesKey.currentContext?.findRenderObject() as RenderBox?;
    var visible = false;
    if (_selectedTab == 0 && box != null && box.attached && box.hasSize) {
      final top = box.localToGlobal(Offset.zero).dy;
      final bottom = top + box.size.height;
      final screen = MediaQuery.sizeOf(context).height;
      // Appears once the section's title is comfortably in view.
      visible = top < screen - 120 && bottom > 80;
    }
    if (visible != _shareButtonVisible) {
      setState(() => _shareButtonVisible = visible);
    }
  }

  Widget _takesSection(
    BuildContext context,
    AppLocalizations l10n,
    MovieReviewsState state,
  ) {
    final takes = state.takes;
    final canShare = _canShare(state);

    return Column(
      key: _takesKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _section(
          context,
          l10n.reviewTakesTitle,
          hint: l10n.reviewTakesHint,
          trailing: canShare
              ? _SectionLink(
                  icon: BootstrapIcons.pencil,
                  label: l10n.filmAddTake,
                  onTap: _openTakeComposer,
                )
              : null,
          switch (takes) {
            AsyncLoading() => LinearProgressIndicator(
                color: _pageBlue,
                backgroundColor: _pageChip,
              ),
            AsyncFailed() => _RetryRow(
                message: l10n.reviewTakesFailed,
                label: l10n.reviewRetry,
                onRetry: _reviews.load,
              ),
            AsyncReady(:final value) when value.isEmpty => Text(
                l10n.reviewTakesEmpty,
                style: TextStyle(color: _pageMuted, fontSize: 14),
              ),
            AsyncReady(:final value) => PeopleTakes(
                takes: value,
                movieId: widget.movie.id,
                repository: widget.reviewRepository,
                cover: TakeCoverInfo(
                  film: Film(
                    imdbId: widget.movie.id,
                    title: widget.movie.title,
                    posterUrl: widget.movie.posterUrl,
                  ),
                  backdropUrl: widget.movie.backdropUrl,
                  year: widget.movie.year,
                ),
              ),
          },
        ),
      ],
    );
  }

  /// One section pattern: title (and optional link or note) outside a dark
  /// rounded card that fills the width.
  Widget _section(
    BuildContext context,
    String title,
    Widget child, {
    String? hint,
    Widget? trailing,
    String? trailingText,
    VoidCallback? onTap,
  }) {
    final radius = BorderRadius.circular(_cardRadius);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(
          context,
          title,
          trailing: trailing ??
              (trailingText == null
                  ? null
                  : Text(
                      trailingText,
                      style: TextStyle(color: _pageMuted, fontSize: 14),
                    )),
        ),
        if (hint != null)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(6, 0, 6, 12),
            child: Text(
              hint,
              style: TextStyle(color: _pageMuted, fontSize: 14),
            ),
          ),
        Material(
          color: _pageCard,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: _pageLine),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeading(
    BuildContext context,
    String title, {
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(6, 0, 6, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: LuxeColors.text,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing],
        ],
      ),
    );
  }

  Widget _castAndCrew(
    BuildContext context,
    Movie movie,
    AppLocalizations l10n,
  ) {
    Widget person(String name, String detail, String? personId) {
      final row = Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: _pageChip,
              child: Text(
                name.characters.first.toUpperCase(),
                style: TextStyle(
                  color: _pageBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: _pageInk,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (detail.isNotEmpty)
                    Text(
                      detail,
                      style: TextStyle(color: _pageMuted, fontSize: 13),
                    ),
                ],
              ),
            ),
            if (personId != null)
              Icon(
                BootstrapIcons.chevron_right,
                color: _pageMuted,
                size: 20,
              ),
          ],
        ),
      );
      if (personId == null) return row;
      return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => PersonScreen(
              personId: personId,
              name: name,
              subtitle: detail,
            ),
          ),
        ),
        child: row,
      );
    }

    final empty = movie.cast.isEmpty && movie.crew.isEmpty;
    return _constrained(
      context,
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (empty)
              _section(
                context,
                '${l10n.overviewTabCast} & ${l10n.overviewTabCrew}',
                Text(
                  _detail == null
                      ? l10n.overviewLoading
                      : l10n.overviewNoCastCrew,
                  style: TextStyle(color: _pageMuted, fontSize: 13),
                ),
              ),
            if (movie.cast.isNotEmpty) ...[
              _section(
                context,
                l10n.overviewTabCast,
                Column(
                  children: [
                    for (final member in movie.cast)
                      person(member.name, member.role, member.personId),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],
            if (movie.crew.isNotEmpty)
              _section(
                context,
                l10n.overviewTabCrew,
                Column(
                  children: [
                    for (final member in movie.crew)
                      person(member.name, member.job, member.personId),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _offerLabel(AppLocalizations l10n, ProviderOffer? offer) =>
      switch (offer) {
        ProviderOffer.subscription => l10n.overviewOfferStream,
        ProviderOffer.free => l10n.overviewOfferFree,
        ProviderOffer.tvProvider => l10n.overviewOfferTvProvider,
        ProviderOffer.rent => l10n.overviewOfferRent,
        ProviderOffer.buy => l10n.overviewOfferBuy,
        null => l10n.overviewWhereToWatch,
      };

  Widget _watchProviders(
    BuildContext context,
    Movie movie,
    AppLocalizations l10n,
  ) {
    final providers = movie.watchProviders;
    final available = providers?.available ?? const <StreamingProvider>[];
    final groups = <ProviderOffer?, List<StreamingProvider>>{};
    for (final provider in available) {
      groups.putIfAbsent(provider.offer, () => []).add(provider);
    }

    return _constrained(
      context,
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
        child: _section(
          context,
          l10n.overviewWhereToWatch,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (available.isEmpty)
                Text(
                  l10n.overviewNoStreaming,
                  style: TextStyle(color: _pageMuted, fontSize: 13),
                )
              else
                for (final entry in groups.entries) ...[
                  if (entry.key != groups.keys.first)
                    const SizedBox(height: 16),
                  Text(
                    _offerLabel(l10n, entry.key),
                    style: TextStyle(
                      color: _pageMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = (constraints.maxWidth - 8) / 2;
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final provider in entry.value)
                            SizedBox(
                              width: width,
                              child: StreamingProviderLogo(provider: provider),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              if (providers?.link case final link?) ...[
                const SizedBox(height: 12),
                SelectableText(
                  link,
                  style: TextStyle(color: _pageBlue, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _constrained(BuildContext context, Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.tokens.maxContentWidth),
        child: child,
      ),
    );
  }
}

extension on Set<String> {
  void toggle(String value, bool add) => add ? this.add(value) : remove(value);
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.busy = false,
  });

  final IconData icon;
  final String label;
  final bool active;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // On: white on the accent pill (black in light mode). Off: page ink.
    final color = active ? Colors.white : _pageInk;
    // Three equal buttons on one row, so they never wrap on a phone.
    return Expanded(
      child: Semantics(
        button: true,
        selected: active,
        label: label,
        excludeSemantics: true,
        child: InkWell(
          borderRadius: BorderRadius.circular(21),
          onTap: busy ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            // Same look as the Home tabs: blue gradient pill when on, matte
            // surface with a hairline when off.
            decoration: BoxDecoration(
              color: active ? null : LuxeColors.surface2,
              gradient: active ? LuxeColors.accentGradient : null,
              border: active ? null : Border.all(color: LuxeColors.hair),
              borderRadius: BorderRadius.circular(12),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: LuxeColors.accent.withValues(alpha: .35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (busy)
                  SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                else
                  Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: color, fontSize: 13),
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

/// Blue text link on the right of a section title ("Clear", "Add take").
class _SectionLink extends StatelessWidget {
  const _SectionLink({required this.label, required this.onTap, this.icon});

  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: _pageBlue,
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
    );
  }
}

/// Overview / Cast & crew / Where to watch, pinned under the collapsed
/// header. As it reaches the top it shrinks a little and gains a backdrop.
class _TabsHeader extends SliverPersistentHeaderDelegate {
  _TabsHeader({
    required this.labels,
    required this.selected,
    required this.onSelected,
    required this.maxWidth,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;
  final double maxWidth;

  static const _max = 66.0;
  static const _min = 52.0;

  @override
  double get maxExtent => _max;

  @override
  double get minExtent => _min;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    final t = (shrinkOffset / (_max - _min)).clamp(0.0, 1.0);
    final stuck = overlaps || t > 0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _pageBackground,
        border: Border(
          bottom: BorderSide(
            color: stuck ? _pageLine : Colors.transparent,
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding:
                EdgeInsets.fromLTRB(16, 4 + 6 * (1 - t), 16, 6 + 4 * (1 - t)),
            child: PillTabs(
              key: const ValueKey('film-detail-tabs'),
              labels: labels,
              selected: selected,
              onSelected: onSelected,
              height: 46 - 8 * t,
              fontSize: 12 - t,
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_TabsHeader old) =>
      old.selected != selected ||
      old.maxWidth != maxWidth ||
      old.labels.join() != labels.join();
}

/// "Share your take", floating over the bottom of the page while "What
/// people said" is on screen. Slides up into view and back down.
class _FloatingShareButton extends StatelessWidget {
  const _FloatingShareButton({
    required this.visible,
    required this.label,
    required this.onTap,
  });

  final bool visible;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration =
        reduceMotion ? Duration.zero : const Duration(milliseconds: 260);

    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        duration: duration,
        curve: Curves.easeOutCubic,
        offset: visible ? Offset.zero : const Offset(0, 1.2),
        child: AnimatedOpacity(
          duration: duration,
          opacity: visible ? 1 : 0,
          child: DecoratedBox(
            // Fades the page out under the button so it reads as floating.
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _pageBackground.withValues(alpha: 0),
                  _pageBackground.withValues(alpha: .92),
                ],
              ),
            ),
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.only(bottom: 12),
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: context.tokens.maxContentWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: _GradientButton(label: label, onTap: onTap),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-width gradient call to action ("Share your take", "Done").
class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  static const _radius = BorderRadius.all(Radius.circular(20));

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LuxeColors.accentGradient,
          borderRadius: _radius,
          boxShadow: [
            BoxShadow(
              color: LuxeColors.accent.withValues(alpha: .35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: _radius,
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 54),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _pageInk,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet to pick up to three feelings as big tiles. Every change is
/// reported through [onChanged]; the page saves when the sheet closes.
class _FeelingsSheet extends StatefulWidget {
  const _FeelingsSheet({required this.initial, required this.onChanged});

  final List<FilmReaction> initial;
  final ValueChanged<List<FilmReaction>> onChanged;

  @override
  State<_FeelingsSheet> createState() => _FeelingsSheetState();
}

class _FeelingsSheetState extends State<_FeelingsSheet> {
  late List<FilmReaction> _picked = List.of(widget.initial);

  void _toggle(FilmReaction feeling) {
    final next = List.of(_picked);
    if (!next.remove(feeling)) {
      if (next.length >= MovieReviewSummary.maxFeelings) return;
      next.add(feeling);
    }
    setState(() => _picked = next);
    widget.onChanged(List.unmodifiable(next));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color:
                      themed(const Color(0xFF262A34), const Color(0xFFCFC8BA)),
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                ),
              ),
            ),
            Text(
              l10n.reviewReactionTitle,
              style: TextStyle(
                color: _pageInk,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _picked.isEmpty
                  ? l10n.filmFeelingsHint
                  : l10n.filmFeelingsCount('${_picked.length}'),
              style: TextStyle(
                color: _picked.length == MovieReviewSummary.maxFeelings
                    ? _pageBlue
                    : _pageMuted,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 18),
            // Scrolls on short screens so Done always stays visible.
            Flexible(
              child: SingleChildScrollView(
                clipBehavior: Clip.none,
                child: FeelingTileGrid(picked: _picked, onToggle: _toggle),
              ),
            ),
            const SizedBox(height: 16),
            _GradientButton(
              label: l10n.filmFeelingsDone,
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet to share a take: pick a card skin (with a live preview of
/// the card), then write the take (up to [_maxTakeLength] characters). Pops
/// how sharing ended, or null when dismissed. When the viewer still has to
/// pick a feeling, the sheet stays open with the draft and says so.
class _TakeComposerSheet extends StatefulWidget {
  const _TakeComposerSheet({required this.onShare});

  final Future<ShareTakeOutcome> Function(
    String body, {
    TakeSkin skin,
    bool spoiler,
  }) onShare;

  @override
  State<_TakeComposerSheet> createState() => _TakeComposerSheetState();
}

class _TakeComposerSheetState extends State<_TakeComposerSheet> {
  final _controller = TextEditingController();
  TakeSkin _skin = TakeSkin.normal;

  /// The author's answer to "Does it have spoilers?"; null until picked.
  bool? _spoiler;
  bool _spoilerMissing = false;
  bool _sending = false;
  bool _needsFeeling = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    final body = _controller.text.trim();
    if (body.isEmpty || _sending) return;
    final spoiler = _spoiler;
    if (spoiler == null) {
      setState(() => _spoilerMissing = true);
      return;
    }
    setState(() {
      _sending = true;
      _needsFeeling = false;
    });
    final outcome = await widget.onShare(body, skin: _skin, spoiler: spoiler);
    if (!mounted) return;
    if (outcome == ShareTakeOutcome.needsFeeling) {
      // Keep the draft: the feeling is picked on the page, then share again.
      setState(() {
        _sending = false;
        _needsFeeling = true;
      });
      return;
    }
    Navigator.of(context).pop(outcome);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final insets = MediaQuery.viewInsetsOf(context).bottom;
    final label = TextStyle(
      color: _pageMuted,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: .3,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: insets),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.filmYourTakeTitle,
                style: TextStyle(
                  color: _pageInk,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.takeSkinTitle, style: label),
              const SizedBox(height: 8),
              TakeSkinPicker(
                selected: _skin,
                enabled: !_sending,
                onChanged: (skin) => setState(() => _skin = skin),
              ),
              const SizedBox(height: 16),
              Text(l10n.takeSkinPreview, style: label),
              const SizedBox(height: 8),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, _) => SpoilerShield(
                  // Re-blurs whenever the answer changes to "spoilers".
                  key: ValueKey(_spoiler),
                  hidden: _spoiler == true,
                  child: TakeSkinPreview(skin: _skin, text: value.text),
                ),
              ),
              const SizedBox(height: 16),
              SpoilerChoice(
                value: _spoiler,
                enabled: !_sending,
                showError: _spoilerMissing,
                onChanged: (value) => setState(() {
                  _spoiler = value;
                  _spoilerMissing = false;
                }),
              ),
              if (_needsFeeling) ...[
                const SizedBox(height: 16),
                Semantics(
                  liveRegion: true,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        BootstrapIcons.info_circle,
                        color: LuxeColors.accentHi,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.reviewNeedsFeeling,
                          style: TextStyle(
                            color: LuxeColors.text,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(l10n.takeSkinWriteTitle, style: label),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                enabled: !_sending,
                autofocus: true,
                minLines: 3,
                maxLines: 10,
                maxLength: _maxTakeLength,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _share(),
                style: TextStyle(color: _pageInk, fontSize: 16),
                decoration: InputDecoration(
                  hintText: l10n.reviewWhyHint,
                  hintStyle: TextStyle(color: _pageMuted, fontSize: 15),
                  counterStyle: TextStyle(color: _pageMuted, fontSize: 11),
                  filled: true,
                  fillColor: _pageChip,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: _sending
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          tooltip: l10n.reviewShare,
                          onPressed: _share,
                          icon: Icon(
                            BootstrapIcons.send_fill,
                            color: _pageBlue,
                            size: 22,
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

class _RetryRow extends StatelessWidget {
  const _RetryRow({
    required this.message,
    required this.label,
    required this.onRetry,
  });

  final String message;
  final String label;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: TextStyle(color: _pageMuted, fontSize: 13),
          ),
        ),
        TextButton(onPressed: onRetry, child: Text(label)),
      ],
    );
  }
}
