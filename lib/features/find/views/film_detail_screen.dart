import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/find_repository.dart';
import '../data/movie.dart';
import 'widgets/streaming_provider_logo.dart';

const _pageBackground = Color(0xFF111111);
const _pageCard = Color(0xFF1B1E27);
const _pageChip = Color(0xFF1B2030);
const _pageBlue = Color(0xFF2F7BF5);
const _pageMuted = Color(0xFF9A9CA5);
const _pageLine = Color(0x33FFFFFF);

class FilmDetailScreen extends StatefulWidget {
  const FilmDetailScreen({
    super.key,
    required this.movie,
    this.repository,
    this.heroTag,
    this.footer,
  });

  final Movie movie;
  final FindRepository? repository;
  final Object? heroTag;
  final Widget? footer;

  @override
  State<FilmDetailScreen> createState() => _FilmDetailScreenState();
}

class _FilmDetailScreenState extends State<FilmDetailScreen> {
  late final FindRepository _repository;
  final _takeController = TextEditingController();
  Movie? _detail;
  List<String> _stills = const [];
  int _selectedTab = 0;
  bool _overviewExpanded = false;
  bool? _watchedPreview;
  bool? _watchlistPreview;
  List<int> _selectedMoods = [0, 1, 2];

  final List<_DemoTake> _myTakes = [];
  final List<_DemoTake> _friendsTakes = [
    _DemoTake(
      author: 'Cinema fan',
      date: 'Oct 21, 2026',
      text:
          'The atmosphere and sound design make this one worth seeing on a big screen.',
      reactedMoods: [6, 1],
      counts: [2, 9, 0],
    ),
  ];
  final List<_DemoTake> _popularTakes = [
    _DemoTake(
      author: 'Film lover',
      date: 'Nov 2, 2026',
      text: 'A few scenes stayed with me long after the credits.',
      reactedMoods: [2, 0],
      counts: [31, 210, 18],
    ),
    _DemoTake(
      author: 'Movie watcher',
      date: 'Nov 8, 2026',
      text: 'Not for everyone, but I enjoyed its slower moments.',
      reactedMoods: [7],
      counts: [7, 64, 22],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? FindRepository();
    _load();
    _loadStills();
  }

  @override
  void dispose() {
    _takeController.dispose();
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

  void _postTake() {
    final text = _takeController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _myTakes.insert(
        0,
        _DemoTake(
          author: 'You',
          date: 'Today',
          text: text,
          reactedMoods: List<int>.of(_selectedMoods),
        ),
      );
      _takeController.clear();
    });
    FocusScope.of(context).unfocus();
  }

  void _vote(_DemoTake take, int index) {
    setState(() {
      if (take.vote == index) {
        take.counts[index] = (take.counts[index] - 1).clamp(0, 1 << 30);
        take.vote = null;
        return;
      }

      if (take.vote case final previous?) {
        take.counts[previous] = (take.counts[previous] - 1).clamp(0, 1 << 30);
      }
      take.counts[index]++;
      take.vote = index;
    });
  }

  Future<void> _pickMoods(
    BuildContext context,
    List<_Mood> moods,
  ) async {
    final temporary = List<int>.of(_selectedMoods);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: _pageCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.reviewReactionTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose up to 3 (${temporary.length}/3)',
                  style: const TextStyle(color: _pageMuted, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    for (var index = 0; index < moods.length; index++)
                      _MoodChoice(
                        mood: moods[index],
                        selected: temporary.contains(index),
                        onTap: () => setSheetState(() {
                          if (temporary.contains(index)) {
                            temporary.remove(index);
                          } else if (temporary.length < 3) {
                            temporary.add(index);
                          }
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: _pageBlue),
                    onPressed: () {
                      setState(() => _selectedMoods = List<int>.of(temporary));
                      Navigator.of(sheetContext).pop();
                    },
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final movie = _detail ?? widget.movie;
    final moods = _moods(l10n);

    return Scaffold(
      backgroundColor: _pageBackground,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _hero(context, movie, l10n),
          if (_selectedTab == 0) _overview(context, movie, l10n, moods),
          if (_selectedTab == 1 || _selectedTab == 3)
            _comingSoon(context, l10n),
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
      'ARTICLES',
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
                      colors: [Color(0x00000000), Color(0xEE111111)],
                    ),
                  ),
                ),
              ),
              const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  size: 60,
                  color: Colors.white70,
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          key: const ValueKey('film-detail-tabs'),
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth - 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var index = 0; index < labels.length; index++)
                  InkWell(
                    onTap: () => setState(() => _selectedTab = index),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color:
                                _selectedTab == index ? _pageBlue : _pageLine,
                            width: _selectedTab == index ? 2.5 : 1,
                          ),
                        ),
                      ),
                      child: Text(
                        labels[index],
                        style: TextStyle(
                          color: _selectedTab == index
                              ? Colors.white
                              : Colors.white70,
                          fontSize: 12,
                          letterSpacing: .3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _overview(
    BuildContext context,
    Movie movie,
    AppLocalizations l10n,
    List<_Mood> moods,
  ) {
    final selectedWatchlist = _watchlistPreview ?? movie.isWatchlist;
    final selectedWatched = _watchedPreview ?? movie.isWatched;

    return _constrained(
      context,
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _movieSummary(context, movie, l10n),
            const SizedBox(height: 14),
            Wrap(
            
              spacing: 10,
              runSpacing: 8,
              children: [
                _ActionPill(
                  icon: selectedWatched
                      ? Icons.visibility
                      : Icons.visibility_outlined,
                  label: l10n.homeWatchedTitle,
                  active: selectedWatched,
                  onTap: () => setState(
                    () => _watchedPreview = !selectedWatched,
                  ),
                ),
                _ActionPill(
                  icon: selectedWatchlist
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  label: l10n.homeWatchlistTitle,
                  active: selectedWatchlist,
                  onTap: () => setState(
                    () => _watchlistPreview = !selectedWatchlist,
                  ),
                ),
                _ActionPill(
                  icon: Icons.send_outlined,
                  label: 'SAGE',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.homeComingSoon)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                'List buttons are a local preview.',
                style: TextStyle(color: _pageMuted, fontSize: 10),
              ),
            ),
            const SizedBox(height: 12),
            _experience(context, l10n, moods),
            const SizedBox(height: 20),
            _audience(context, l10n, moods),
            const SizedBox(height: 20),
            _takes(context, l10n, moods),
          ],
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

  Widget _experience(
    BuildContext context,
    AppLocalizations l10n,
    List<_Mood> moods,
  ) {
    return _section(
      context,
      l10n.reviewReactionTitle,
      Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 40),
              Expanded(
                child: Text(
                  l10n.reviewReactionHint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
              IconButton(
                tooltip: 'Choose up to 3 feelings',
                icon: const Icon(Icons.info_outline, color: Colors.white54),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pick up to 3 feelings for this demo.'),
                  ),
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () => _pickMoods(context, moods),
            borderRadius: BorderRadius.circular(40),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Icon(
                Icons.sentiment_satisfied_alt,
                color: _pageBlue,
                size: 54,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _pickMoods(context, moods),
            child: Text(
              '${l10n.reviewReactionChange} · ${_selectedMoods.length}/3',
              style: const TextStyle(color: _pageMuted, fontSize: 11),
            ),
          ),
          const Divider(color: _pageLine, height: 12),
          Row(
            children: [
              Expanded(
                child: _selectedMoods.isEmpty
                    ? const Text(
                        'No feelings picked yet.',
                        style: TextStyle(color: _pageMuted, fontSize: 12),
                      )
                    : Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          for (final index in _selectedMoods)
                            _SelectedMood(mood: moods[index]),
                        ],
                      ),
              ),
              IconButton(
                tooltip: l10n.reviewReactionChange,
                icon: const Icon(Icons.edit_outlined, color: _pageBlue),
                onPressed: () => _pickMoods(context, moods),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _audience(
    BuildContext context,
    AppLocalizations l10n,
    List<_Mood> moods,
  ) {
    const reactions = [(0, '8.1K'), (1, '3.2K'), (2, '1.8K')];

    return _section(
      context,
      'The Audience',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _DemoBadge(),
          const SizedBox(height: 12),
          Wrap(
            spacing: 22,
            runSpacing: 12,
            children: [
              for (final (index, count) in reactions)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(moods[index].emoji,
                        style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          moods[index].label,
                          style: const TextStyle(
                            color: _pageBlue,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          count,
                          style: const TextStyle(
                            color: _pageMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _takes(
    BuildContext context,
    AppLocalizations l10n,
    List<_Mood> moods,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _section(
          context,
          l10n.reviewTakesTitle,
          TextField(
            controller: _takeController,
            onSubmitted: (_) => _postTake(),
            textInputAction: TextInputAction.send,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              isDense: true,
              hintText: l10n.overviewAddReviewHint,
              hintStyle: const TextStyle(color: _pageBlue, fontSize: 11),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: _pageBlue),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: _pageBlue, width: 2),
              ),
              suffixIcon: IconButton(
                tooltip: 'Post take',
                onPressed: _postTake,
                icon: const Icon(Icons.send, color: _pageBlue, size: 20),
              ),
            ),
          ),
        ),
        _takeGroup(
          context,
          l10n.overviewYourReview,
          _myTakes,
          moods,
          l10n,
        ),
        _takeGroup(
          context,
          l10n.overviewFriendsReviews,
          _friendsTakes,
          moods,
          l10n,
          demo: true,
        ),
        _takeGroup(
          context,
          l10n.overviewPopularReviews,
          _popularTakes,
          moods,
          l10n,
          demo: true,
        ),
      ],
    );
  }

  Widget _takeGroup(
    BuildContext context,
    String title,
    List<_DemoTake> takes,
    List<_Mood> moods,
    AppLocalizations l10n, {
    bool demo = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(
          context,
          title,
          trailing: demo ? const _DemoBadge() : null,
        ),
        if (takes.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
            child: Text(
              l10n.reviewTakesEmpty,
              style: const TextStyle(color: _pageMuted, fontSize: 12),
            ),
          )
        else
          for (final take in takes)
            _TakeCard(
              take: take,
              moods: moods,
              l10n: l10n,
              onVote: (index) => _vote(take, index),
            ),
      ],
    );
  }

  Widget _section(
    BuildContext context,
    String title,
    Widget child, {
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(context, title, trailing: trailing),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _pageCard,
            borderRadius: BorderRadius.circular(14),
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
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 7),
          const Divider(height: 1, thickness: 1, color: _pageLine),
        ],
      ),
    );
  }

  Widget _watchProviders(
    BuildContext context,
    Movie movie,
    AppLocalizations l10n,
  ) {
    final providers = movie.watchProviders;
    final available = providers?.available ?? const <StreamingProvider>[];

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
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth >= 460
                        ? (constraints.maxWidth - 8) / 2
                        : constraints.maxWidth;
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final provider in available)
                          SizedBox(
                            width: width,
                            child: StreamingProviderLogo(provider: provider),
                          ),
                      ],
                    );
                  },
                ),
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

  Widget _comingSoon(BuildContext context, AppLocalizations l10n) {
    final label = _selectedTab == 1
        ? '${l10n.overviewTabCast} & ${l10n.overviewTabCrew}'
        : 'Articles';

    return _constrained(
      context,
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Center(
          child: Text(
            '$label · ${l10n.homeComingSoon.toLowerCase()}',
            style: const TextStyle(color: _pageMuted),
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

  List<_Mood> _moods(AppLocalizations l10n) => [
        _Mood('❤️', l10n.reviewReactionLoved),
        _Mood('🤯', l10n.reviewReactionBlewMind),
        _Mood('🧠', l10n.reviewReactionMadeThink),
        _Mood('😂', l10n.reviewReactionMadeLaugh),
        _Mood('😢', l10n.reviewReactionMadeCry),
        _Mood('😱', l10n.reviewReactionShocked),
        _Mood('😍', l10n.reviewReactionMasterpiece),
        _Mood('🤔', l10n.reviewReactionBored),
      ];
}

class _Mood {
  const _Mood(this.emoji, this.label);

  final String emoji;
  final String label;
}

class _DemoTake {
  _DemoTake({
    required this.author,
    required this.date,
    required this.text,
    this.reactedMoods = const [],
    List<int>? counts,
  }) : counts = counts ?? [0, 0, 0];

  final String author;
  final String date;
  final String text;
  final List<int> reactedMoods;
  final List<int> counts;
  int? vote;
}

class _DemoBadge extends StatelessWidget {
  const _DemoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _pageChip,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _pageLine),
      ),
      child: const Text(
        'DEMO',
        style: TextStyle(
          color: _pageMuted,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: .5,
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? _pageBlue : Colors.white;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          border: Border.all(color: active ? _pageBlue : Colors.white70),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _MoodChoice extends StatelessWidget {
  const _MoodChoice({
    required this.mood,
    required this.selected,
    required this.onTap,
  });

  final _Mood mood;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 84,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? const Color(0x332F7BF5) : const Color(0xFF242836),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _pageBlue : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Text(mood.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              mood.label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedMood extends StatelessWidget {
  const _SelectedMood({required this.mood});

  final _Mood mood;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(mood.emoji, style: const TextStyle(fontSize: 30)),
        const SizedBox(height: 3),
        Text(
          mood.label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: _pageBlue, fontSize: 10),
        ),
      ],
    );
  }
}

class _TakeCard extends StatelessWidget {
  const _TakeCard({
    required this.take,
    required this.moods,
    required this.l10n,
    required this.onVote,
  });

  final _DemoTake take;
  final List<_Mood> moods;
  final AppLocalizations l10n;
  final ValueChanged<int> onVote;

  @override
  Widget build(BuildContext context) {
    final voteLabels = [
      l10n.reviewVoteChangedMyMind,
      l10n.reviewVoteWellArgued,
      l10n.reviewVoteDisagreeFair,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF2B3550),
            child: Text(
              take.author.isEmpty ? '?' : take.author[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    Text(
                      l10n.overviewReviewBy(take.author, take.date),
                      style: const TextStyle(color: _pageMuted, fontSize: 10),
                    ),
                    for (final index in take.reactedMoods)
                      Text(
                        moods[index].emoji,
                        style: const TextStyle(fontSize: 13),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  take.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    for (var index = 0; index < voteLabels.length; index++)
                      InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => onVote(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: take.vote == index
                                ? const Color(0x442F7BF5)
                                : _pageChip,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: take.vote == index
                                  ? _pageBlue
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${take.counts[index]}',
                                style: const TextStyle(
                                  color: _pageBlue,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                voteLabels[index],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
