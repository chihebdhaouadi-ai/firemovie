import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../find/data/movie.dart';
import '../../find/views/film_detail_screen.dart';
import '../../find/views/widgets/empty_error_views.dart';
import '../data/browse_repository.dart';

/// A poster grid of films, most popular first, optionally for one release
/// [year] or one streaming service. Loads the next page near the end.
class BrowseFilmsScreen extends StatefulWidget {
  const BrowseFilmsScreen({
    super.key,
    required this.title,
    this.year,
    this.serviceId,
    this.genreId,
    this.language,
    this.country,
    this.repository,
  });

  final String title;
  final int? year;
  final int? serviceId;
  final int? genreId;
  final String? language;
  final String? country;
  final BrowseRepository? repository;

  @override
  State<BrowseFilmsScreen> createState() => _BrowseFilmsScreenState();
}

class _BrowseFilmsScreenState extends State<BrowseFilmsScreen> {
  late final BrowseRepository _repository =
      widget.repository ?? ApiBrowseRepository();
  final _scroll = ScrollController();
  final _films = <Movie>[];
  final _seen = <String>{};
  int _page = 0;
  bool _hasMore = true;
  bool _loading = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _loadMore();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.extentAfter < 600) _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final page = await _repository.fetchFilms(
        page: _page + 1,
        year: widget.year,
        serviceId: widget.serviceId,
        genreId: widget.genreId,
        language: widget.language,
        country: widget.country,
      );
      if (!mounted) return;
      setState(() {
        _page = page.page;
        _hasMore = page.hasMore && page.results.isNotEmpty;
        // Pages can shift while popularity changes; skip repeats.
        _films.addAll(page.results.where((film) => _seen.add(film.id)));
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

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    final Widget body;
    if (_films.isEmpty && _failed) {
      body = SearchError(onRetry: _loadMore);
    } else if (_films.isEmpty && _loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_films.isEmpty) {
      body = FindMessageView(
        icon: BootstrapIcons.camera_reels,
        title: l10n.browseFilmsEmpty,
      );
    } else {
      body = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
          child: CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverPadding(
                padding: EdgeInsets.all(tokens.spaceLg),
                sliver: SliverGrid.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 160,
                    mainAxisSpacing: tokens.spaceMd,
                    crossAxisSpacing: tokens.spaceMd,
                    childAspectRatio: 0.52,
                  ),
                  itemCount: _films.length,
                  itemBuilder: (context, index) => _PosterTile(
                    film: _films[index],
                    heroTag: 'browse-${widget.title}-${_films[index].id}',
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _footer(context)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(widget.title),
      ),
      body: SafeArea(top: false, child: body),
    );
  }

  Widget _footer(BuildContext context) {
    final tokens = context.tokens;
    if (_failed) {
      return Padding(
        padding: EdgeInsets.only(bottom: tokens.spaceLg),
        child: Center(
          child: TextButton.icon(
            onPressed: _loadMore,
            icon: const Icon(BootstrapIcons.arrow_clockwise),
            label: Text(context.l10n.findLoadMore),
          ),
        ),
      );
    }
    if (_loading) {
      return Padding(
        padding: EdgeInsets.only(bottom: tokens.spaceLg),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    return SizedBox(height: tokens.spaceLg);
  }
}

class _PosterTile extends StatelessWidget {
  const _PosterTile({required this.film, required this.heroTag});

  final Movie film;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final poster = film.posterUrl;
    final year = film.year;

    return Semantics(
      button: true,
      label: year == null ? film.title : '${film.title}, $year',
      child: ExcludeSemantics(
        child: InkWell(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          onTap: () => Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => FilmDetailScreen(movie: film, heroTag: heroTag),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // The poster takes what the title and year leave, so a
              // two-line title never overflows the tile.
              Expanded(
                child: Hero(
                  tag: heroTag,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(tokens.radiusMd),
                    child: poster == null
                        ? const _PosterFallback()
                        : CachedNetworkImage(
                            imageUrl: poster,
                            fit: BoxFit.cover,
                            memCacheWidth: 342,
                            placeholder: (_, __) =>
                                ColoredBox(color: AppColors.surface),
                            errorWidget: (_, __, ___) =>
                                const _PosterFallback(),
                          ),
                  ),
                ),
              ),
              SizedBox(height: tokens.spaceXs),
              Text(
                film.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              if (year != null)
                Text(
                  '$year',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PosterFallback extends StatelessWidget {
  const _PosterFallback();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceRaised,
      child: Center(
        child: Icon(BootstrapIcons.film, color: AppColors.textMuted),
      ),
    );
  }
}
