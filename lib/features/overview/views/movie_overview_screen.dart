import 'package:flutter/material.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../find/data/find_repository.dart';
import '../../find/data/movie.dart';
import '../../find/views/widgets/film_hero_header.dart';
import '../../film_reviews/data/review_repository.dart';
import '../../film_reviews/presentation/review_section.dart';
import '../../home/data/home_models.dart';
import 'widgets/friend_activity.dart';
import 'widgets/overview_panel.dart';
import 'widgets/status_row.dart';
import 'widgets/where_to_watch_card.dart';
import '../../../core/widgets/game_button.dart';

class MovieOverviewScreen extends StatefulWidget {
  const MovieOverviewScreen({
    super.key,
    required this.film,
    this.repository,
    this.reviewRepository,
  });

  final Film film;
  final FindRepository? repository;
  final ReviewRepository? reviewRepository;

  @override
  State<MovieOverviewScreen> createState() => _MovieOverviewScreenState();
}

class _MovieOverviewScreenState extends State<MovieOverviewScreen> {
  late final FindRepository _repository;
  Movie? _detail;
  bool _loading = true;
  bool _failed = false;
  List<String> _stills = const [];

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? FindRepository();
    _load();
    _loadStills();
  }

  Future<void> _loadStills() async {
    try {
      final stills = await _repository.fetchStills(widget.film.imdbId);
      if (mounted) setState(() => _stills = stills);
    } catch (_) {
      // The header keeps the poster until stills are available.
    }
  }

  Future<void> _load() async {
    try {
      final detail = await _repository.fetchDetail(widget.film.imdbId);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  void _retry() {
    setState(() {
      _loading = true;
      _failed = false;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final detail = _detail;
    final summary = Movie(
      id: widget.film.imdbId,
      title: widget.film.displayTitle,
      posterUrl: widget.film.posterUrl,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: FilmHeroHeader(
              movie: detail ?? summary,
              stills: _stills,
              overviewMode: true,
            ),
          ),
          _contentSliver([
            if (_loading)
              LinearProgressIndicator(
                color: AppColors.accentGlow,
                backgroundColor: AppColors.surfaceRaised,
              ),
            if (detail != null) ..._loadedSections(detail),
            if (_failed) _ErrorCard(onRetry: _retry),
          ]),
          if (detail != null)
            ReviewSection(
              movieId: widget.film.imdbId,
              repository: widget.reviewRepository,
            ),
          _contentSliver([
            Text(
              l10n.findAttribution,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _contentSliver(List<Widget> children) {
    final tokens = context.tokens;

    return SliverToBoxAdapter(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              tokens.spaceLg,
              tokens.spaceLg,
              tokens.spaceLg,
              tokens.spaceMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _loadedSections(Movie detail) {
    final tokens = context.tokens;

    return [
      StatusRow(movie: detail),
      SizedBox(height: tokens.spaceLg),
      WhereToWatchCard(providers: detail.watchProviders),
      SizedBox(height: tokens.spaceMd),
      FriendActivity(
        movieId: widget.film.imdbId,
        repository: widget.reviewRepository,
      ),
    ];
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.only(top: tokens.spaceLg),
      child: OverviewPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.findDetailsErrorTitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
            SizedBox(height: tokens.spaceSm),
            GameButton(
              label: l10n.findDetailsRetry,
              style: GameButtonStyle.blue,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
