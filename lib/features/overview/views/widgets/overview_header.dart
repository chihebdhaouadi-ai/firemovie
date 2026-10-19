import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../find/data/movie.dart';
import '../../../home/views/widgets/film_tile.dart';
import '../../data/overview_placeholders.dart';
import 'overview_panel.dart';

const _posterWidth = 108.0;

class OverviewHeader extends StatelessWidget {
  const OverviewHeader({super.key, required this.movie, required this.loaded});

  final Movie movie;
  final bool loaded;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Poster(url: movie.posterUrl, width: _posterWidth),
        SizedBox(width: tokens.spaceMd),
        Expanded(child: _InfoPanel(movie: movie, loaded: loaded)),
      ],
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({required this.url, required this.width});

  final String? url;
  final double width;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final imageUrl = url;

    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radiusMd),
      child: SizedBox(
        width: width,
        height: tokens.posterHeight(width),
        child: imageUrl == null
            ? const PosterPlaceholder()
            : CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => const PosterPlaceholder(),
                errorWidget: (_, __, ___) => const PosterPlaceholder(),
              ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.movie, required this.loaded});

  final Movie movie;
  final bool loaded;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final meta = [
      if (movie.year != null) '${movie.year}',
      if (movie.runtime != null) l10n.findDetailsRuntime(movie.runtime!),
    ].join(' · ');
    final director = movie.director;
    final overview = movie.overview;

    return OverviewPanel(
      borderColor: AppColors.panelBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            movie.displayTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          if (meta.isNotEmpty) ...[
            SizedBox(height: tokens.spaceXs),
            Text(
              meta,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
          if (director != null) ...[
            SizedBox(height: tokens.spaceXs),
            Text(
              '${l10n.findDirectedBy} $director',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (loaded && overview != null) ...[
            SizedBox(height: tokens.spaceSm),
            Text(
              overview,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (loaded) ...[
            SizedBox(height: tokens.spaceMd),
            _InfoTabs(movie: movie),
          ],
        ],
      ),
    );
  }
}

class _InfoTabs extends StatefulWidget {
  const _InfoTabs({required this.movie});

  final Movie movie;

  @override
  State<_InfoTabs> createState() => _InfoTabsState();
}

class _InfoTabsState extends State<_InfoTabs> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final labels = [
      l10n.overviewTabGenres,
      l10n.overviewTabCast,
      l10n.overviewTabCrew,
      l10n.overviewTabProd,
    ];
    final items = [
      widget.movie.genres,
      OverviewPlaceholders.cast,
      OverviewPlaceholders.crew,
      OverviewPlaceholders.production,
    ];
    final current = items[_selected];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          children: [
            for (var i = 0; i < labels.length; i++)
              Semantics(
                selected: i == _selected,
                child: TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: Size(0, tokens.minTouchTarget),
                    padding: EdgeInsets.symmetric(horizontal: tokens.spaceXs),
                  ),
                  onPressed: () => setState(() => _selected = i),
                  child: Text(
                    labels[i],
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: i == _selected
                          ? AppColors.accentGlow
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
          ],
        ),
        Text(
          current.isEmpty ? l10n.overviewNoGenres : current.join(' · '),
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
