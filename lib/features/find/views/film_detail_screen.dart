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
import '../../film_reviews/domain/take_tag.dart';
import '../../film_reviews/presentation/state/movie_reviews_cubit.dart';
import '../../film_reviews/presentation/state/movie_reviews_state.dart';
import '../../film_reviews/presentation/widgets/feeling_chip.dart';
import '../../film_reviews/presentation/widgets/people_takes.dart';
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
const _pageBackground = LuxeColors.bg;
const _pageCard = LuxeColors.surface;
const _pageChip = LuxeColors.surface2;
const _pageBlue = LuxeColors.accent;
const _pageMuted = LuxeColors.muted;
const _pageLine = LuxeColors.hair;
const _cardRadius = 28.0;

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

  /// Picks or drops one feeling (up to three). The chip lights at once; the
  /// save follows, and taps made while it runs are sent together after it.
  void _toggleFeeling(List<FilmReaction> current, FilmReaction feeling) {
    final next = List.of(_draftFeelings ?? current);
    if (!next.remove(feeling)) {
      if (next.length >= MovieReviewSummary.maxFeelings) return;
      next.add(feeling);
    }
    setState(() => _draftFeelings = next);
    _saveFeelings();
  }

  void _clearFeelings() {
    setState(() => _draftFeelings = const []);
    _saveFeelings();
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
    final shared = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: _pageCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(_cardRadius)),
      ),
      builder: (_) => _TakeComposerSheet(onShare: _reviews.shareTake),
    );
    if (shared == null || !mounted) return;
    _snack(shared ? l10n.reviewSharedThanks : l10n.reviewTakeFailed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final movie = _detail ?? widget.movie;

    return BlocProvider.value(
      value: _reviews,
      child: Scaffold(
        backgroundColor: _pageBackground,
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            _hero(context, movie, l10n),
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _hero(BuildContext context, Movie movie, AppLocalizations l10n) {
    final backdrop = _stills.isNotEmpty
        ? _stills.first
        : movie.backdropUrl ?? movie.posterUrl;
    final labels = [
      l10n.findDetailsOverview.toUpperCase(),
      '${l10n.overviewTabCast} & ${l10n.overviewTabCrew}',
      l10n.overviewWhereToWatch.toUpperCase(),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.tokens.maxContentWidth),
        child: SizedBox(
          key: const ValueKey('film-detail-header'),
          width: double.infinity,
          height: 310,
          child: Stack(
            children: [
              Positioned.fill(
                child: Hero(
                  tag: widget.heroTag ?? 'detail-${movie.id}',
                  child: _coverImage(backdrop),
                ),
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00000000), Color(0xF20E0F12)],
                    ),
                  ),
                ),
              ),
              Center(
                child: IconButton(
                  tooltip: l10n.overviewPlayTrailer,
                  iconSize: 60,
                  onPressed: () => _openTrailer(movie),
                  icon: const Icon(
                    Icons.play_circle_outline,
                    color: Colors.white70,
                  ),
                ),
              ),
              Positioned(
                // viewPadding: the ListView strips the top inset from padding.
                top: MediaQuery.viewPaddingOf(context).top + 8,
                left: 8,
                child: IconButton(
                  tooltip: l10n.overviewBack,
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () => Navigator.maybePop(context),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _tabBar(labels),
              ),
            ],
          ),
        ),
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

  Widget _tabBar(List<String> labels) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: PillTabs(
        key: const ValueKey('film-detail-tabs'),
        labels: labels,
        selected: _selectedTab,
        onSelected: (index) => setState(() => _selectedTab = index),
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
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                        watched ? Icons.visibility : Icons.visibility_outlined,
                    label: l10n.homeWatchedTitle,
                    active: watched,
                    busy: _listBusy.contains(FilmListId.watched),
                    onTap: () => _toggleList(movie, FilmListId.watched),
                  ),
                  const SizedBox(width: 8),
                  _ActionPill(
                    icon: watchlist ? Icons.bookmark : Icons.bookmark_border,
                    label: l10n.homeWatchlistTitle,
                    active: watchlist,
                    busy: _listBusy.contains(FilmListId.watchlist),
                    onTap: () => _toggleList(movie, FilmListId.watchlist),
                  ),
                  const SizedBox(width: 8),
                  _ActionPill(
                    icon: Icons.send_outlined,
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
                          color: Colors.white,
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
                        style: const TextStyle(
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
                        style: const TextStyle(color: Colors.white70),
                      ),
                      TextSpan(
                        text: movie.director,
                        style: const TextStyle(
                          color: Colors.white,
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
                style: const TextStyle(
                  color: Colors.white70,
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
                    style: const TextStyle(color: _pageBlue, fontSize: 11),
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
      style: const TextStyle(color: Colors.white70, fontSize: 11),
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

    return _section(
      context,
      l10n.reviewReactionTitle,
      hint: feelings.isEmpty
          ? l10n.filmFeelingsHint
          : l10n.filmFeelingsCount('${feelings.length}'),
      trailing: feelings.isEmpty
          ? null
          : _SectionLink(label: l10n.filmFeelingsClear, onTap: _clearFeelings),
      switch (summary) {
        AsyncLoading() => const LinearProgressIndicator(
            color: _pageBlue,
            backgroundColor: _pageChip,
          ),
        AsyncFailed() => _RetryRow(
            message: l10n.reviewSummaryFailed,
            label: l10n.reviewRetry,
            onRetry: _reviews.load,
          ),
        AsyncReady() => FeelingPicker(
            picked: feelings,
            onToggle: (feeling) => _toggleFeeling(saved, feeling),
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
    final percent = value.everyonePercent;
    final hasCounts = value.allCounts.any((item) => item.count > 0);

    return _section(
      context,
      l10n.filmAudienceTitle,
      trailingText:
          value.total == 0 ? null : l10n.filmAudiencePeople(value.total),
      value.total == 0 || !hasCounts
          ? Text(
              l10n.filmAudienceEmpty,
              style: const TextStyle(color: _pageMuted, fontSize: 14),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (percent != null) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$percent%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.filmAudiencePositive,
                          style: const TextStyle(
                            color: _pageMuted,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                AudienceBar(counts: value.allCounts),
              ],
            ),
    );
  }

  Widget _takesSection(
    BuildContext context,
    AppLocalizations l10n,
    MovieReviewsState state,
  ) {
    final takes = state.takes;
    // One review per person: once the viewer has shared theirs, the button goes.
    final hasOwnReview = takes is AsyncReady<List<Take>> &&
        takes.value.any((take) => take.isMine && take.tag == TakeTag.review);
    final canShare = takes is AsyncReady<List<Take>> && !hasOwnReview;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _section(
          context,
          l10n.reviewTakesTitle,
          hint: l10n.reviewTakesHint,
          trailing: canShare
              ? _SectionLink(
                  icon: Icons.edit_outlined,
                  label: l10n.filmAddTake,
                  onTap: _openTakeComposer,
                )
              : null,
          switch (takes) {
            AsyncLoading() => const LinearProgressIndicator(
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
                style: const TextStyle(color: _pageMuted, fontSize: 14),
              ),
            AsyncReady(:final value) => PeopleTakes(
                takes: value,
                movieId: widget.movie.id,
                repository: widget.reviewRepository,
              ),
          },
        ),
        if (canShare) ...[
          const SizedBox(height: 14),
          _ShareTakeButton(
            label: l10n.filmShareYourTake,
            onTap: _openTakeComposer,
          ),
        ],
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
  }) {
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
                      style: const TextStyle(color: _pageMuted, fontSize: 14),
                    )),
        ),
        if (hint != null)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(6, 0, 6, 12),
            child: Text(
              hint,
              style: const TextStyle(color: _pageMuted, fontSize: 14),
            ),
          ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _pageCard,
            borderRadius: BorderRadius.circular(_cardRadius),
            border: Border.all(color: _pageLine),
          ),
          child: child,
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
                style: const TextStyle(
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (detail.isNotEmpty)
                    Text(
                      detail,
                      style: const TextStyle(color: _pageMuted, fontSize: 13),
                    ),
                ],
              ),
            ),
            if (personId != null)
              const Icon(
                Icons.chevron_right_rounded,
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
                  style: const TextStyle(color: _pageMuted, fontSize: 13),
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
                  style: const TextStyle(color: _pageMuted, fontSize: 13),
                )
              else
                for (final entry in groups.entries) ...[
                  if (entry.key != groups.keys.first)
                    const SizedBox(height: 16),
                  Text(
                    _offerLabel(l10n, entry.key),
                    style: const TextStyle(
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
                  style: const TextStyle(color: _pageBlue, fontSize: 12),
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
    const color = Colors.white;
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

/// Full-width gradient call to action under "What people said".
class _ShareTakeButton extends StatelessWidget {
  const _ShareTakeButton({required this.label, required this.onTap});

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
                    style: const TextStyle(
                      color: Colors.white,
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

/// Bottom sheet to write a take (280 characters). Pops true once shared,
/// false if sharing failed, null when dismissed.
class _TakeComposerSheet extends StatefulWidget {
  const _TakeComposerSheet({required this.onShare});

  final Future<bool> Function(String body) onShare;

  @override
  State<_TakeComposerSheet> createState() => _TakeComposerSheetState();
}

class _TakeComposerSheetState extends State<_TakeComposerSheet> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    final body = _controller.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    final shared = await widget.onShare(body);
    if (!mounted) return;
    Navigator.of(context).pop(shared);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final insets = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: insets),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.filmYourTakeTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                enabled: !_sending,
                autofocus: true,
                minLines: 2,
                maxLines: 5,
                maxLength: 280,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _share(),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: l10n.reviewWhyHint,
                  hintStyle: const TextStyle(color: _pageMuted, fontSize: 15),
                  counterStyle:
                      const TextStyle(color: _pageMuted, fontSize: 11),
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
                          icon: const Icon(
                            Icons.send,
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
            style: const TextStyle(color: _pageMuted, fontSize: 13),
          ),
        ),
        TextButton(onPressed: onRetry, child: Text(label)),
      ],
    );
  }
}
