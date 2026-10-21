import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/find_repository.dart';
import '../data/movie.dart';
import 'widgets/film_hero_header.dart';

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
  late FindRepository _repository;
  Movie? _detail;
  List<String> _stills = const [];

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? FindRepository();
    _load();
    _loadStills();
  }

  Future<void> _load() async {
    try {
      final detail = await _repository.fetchDetail(widget.movie.id);
      if (mounted) setState(() => _detail = detail);
    } catch (_) {
      // Fall back to the already-known summary.
    }
  }

  Future<void> _loadStills() async {
    try {
      final stills = await _repository.fetchStills(widget.movie.id);
      if (mounted) setState(() => _stills = stills);
    } catch (_) {
      // The header keeps the poster until stills are available.
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final movie = _detail ?? widget.movie;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: FilmHeroHeader(
              movie: movie,
              heroTag: widget.heroTag,
              stills: _stills,
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    tokens.spaceLg,
                    tokens.spaceLg,
                    tokens.spaceLg,
                    tokens.spaceXl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (movie.watchProviders != null) ...[
                        _WatchWhere(
                          providers: movie.watchProviders!,
                          l10n: l10n,
                        ),
                        SizedBox(height: tokens.spaceLg),
                      ],
                      if (widget.footer != null) ...[
                        widget.footer!,
                        SizedBox(height: tokens.spaceLg),
                      ],
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
            ),
          ),
        ],
      ),
    );
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
