import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/find_repository.dart';
import '../data/movie.dart';

/// A full film detail screen backed by the backend TMDB proxy.
///
/// Reads an initial [Movie] for an instant hero transition, then fetches the
/// richer detail payload (director, cast, genres, overview, runtime, rating,
/// where to watch).
class FilmDetailScreen extends StatefulWidget {
  const FilmDetailScreen({
    super.key,
    required this.movie,
    this.repository,
    this.heroTag,
  });

  final Movie movie;
  final FindRepository? repository;
  final Object? heroTag;

  @override
  State<FilmDetailScreen> createState() => _FilmDetailScreenState();
}

class _FilmDetailScreenState extends State<FilmDetailScreen> {
  late FindRepository _repository;
  Movie? _detail;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? FindRepository();
    _load();
  }

  Future<void> _load() async {
    try {
      final detail = await _repository.fetchDetail(widget.movie.id);
      if (mounted) setState(() => _detail = detail);
    } catch (_) {
      // Fall back to the already-known summary.
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final movie = _detail ?? widget.movie;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 260,
              backgroundColor: AppColors.background,
              elevation: 0,
              scrolledUnderElevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: widget.heroTag ?? 'detail-${movie.id}',
                  child: _backdrop(movie),
                ),
              ),
              leading: IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            SliverPadding(
              padding: EdgeInsetsDirectional.fromSTEB(
                tokens.spaceLg,
                tokens.spaceLg,
                tokens.spaceLg,
                tokens.spaceXl,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.textPrimary,
                              ),
                    ),
                    SizedBox(height: tokens.spaceXs),
                    Text(
                      _subtitle(movie),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                    if (movie.genres.isNotEmpty) ...[
                      SizedBox(height: tokens.spaceSm),
                      Wrap(
                        spacing: tokens.spaceXs,
                        children: [
                          for (final genre in movie.genres)
                            _chip(context, genre),
                        ],
                      ),
                    ],
                    if (movie.overview != null) ...[
                      SizedBox(height: tokens.spaceLg),
                      Text(
                        l10n.findDetailsOverview,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      SizedBox(height: tokens.spaceXs),
                      Text(
                        movie.overview!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                    if (movie.watchProviders != null) ...[
                      SizedBox(height: tokens.spaceLg),
                      _WatchWhere(
                        providers: movie.watchProviders!,
                        l10n: l10n,
                      ),
                    ],
                    SizedBox(height: tokens.spaceLg),
                    Text(
                      l10n.findAttribution,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _backdrop(Movie movie) {
    final url = movie.backdropUrl ?? movie.posterUrl;
    if (url == null) {
      return ColoredBox(
        color: AppColors.surface,
        child: Center(
          child: Icon(
            Icons.movie_outlined,
            size: 64,
            color: AppColors.textMuted,
          ),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => const ColoredBox(color: AppColors.surface),
      errorWidget: (_, __, ___) => const ColoredBox(color: AppColors.surface),
    );
  }

  Widget _chip(BuildContext context, String label) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(context.tokens.radiusSm),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: context.tokens.spaceSm,
          vertical: 4,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.accentGlow,
              ),
        ),
      ),
    );
  }

  String _subtitle(Movie movie) {
    final parts = <String>[
      if (movie.year != null) '${movie.year}',
      if (movie.director != null)
        '${context.l10n.findDirectedBy} ${movie.director}',
      if (movie.runtime != null)
        context.l10n.findDetailsRuntime(movie.runtime!),
      if (movie.voteAverage != null)
        context.l10n.findDetailsVote(movie.voteAverage!.toStringAsFixed(1)),
    ];
    return parts.join(' · ');
  }
}

class _WatchWhere extends StatelessWidget {
  const _WatchWhere({required this.providers, required this.l10n});

  final WatchProviders providers;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final flatrate = providers.flatrate;
    final link = providers.link;

    final title = Row(
      children: [
        Icon(Icons.play_circle_outline, size: 18, color: AppColors.accentGlow),
        SizedBox(width: context.tokens.spaceXs),
        Text(
          l10n.findWatchNow,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );

    if (flatrate.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          if (link != null) ...[
            SizedBox(height: context.tokens.spaceSm),
            Text(link.replaceAll('https://', ''),
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title,
        SizedBox(height: context.tokens.spaceSm),
        Wrap(
          spacing: context.tokens.spaceSm,
          runSpacing: context.tokens.spaceSm,
          children: [
            for (final provider in flatrate) _ProviderLogo(provider: provider),
          ],
        ),
        if (link != null) ...[
          SizedBox(height: context.tokens.spaceSm),
          Text(
            link,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.accentGlow,
                ),
          ),
        ],
      ],
    );
  }
}

class _ProviderLogo extends StatelessWidget {
  const _ProviderLogo({required this.provider});

  final StreamingProvider provider;

  @override
  Widget build(BuildContext context) {
    final url = provider.logoUrl;
    if (url == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(context.tokens.radiusSm),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(provider.name),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.tokens.radiusSm),
      child: CachedNetworkImage(
        imageUrl: url,
        width: 32,
        height: 32,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) =>
            const ColoredBox(color: AppColors.surfaceRaised),
      ),
    );
  }
}
