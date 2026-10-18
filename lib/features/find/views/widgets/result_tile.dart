import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/movie.dart';
import 'add_button.dart';

/// One search result row: poster, title/year, director, optional genre chip,
/// and a trailing add action. The row opens details; long-press reveals a menu.
class ResultTile extends StatelessWidget {
  const ResultTile({
    super.key,
    required this.movie,
    required this.added,
    required this.processing,
    required this.onAdd,
    required this.onOpen,
    this.onLongPressMenu,
    this.heroTag,
    this.addSemantics,
  });

  final Movie movie;
  final bool added;
  final bool processing;
  final VoidCallback onAdd;
  final VoidCallback onOpen;
  final VoidCallback? onLongPressMenu;
  final Object? heroTag;
  final String? addSemantics;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final directedBy = movie.director;
    final action = added ? 'Added' : 'Add';

    final semanticsLabel = l10n.findResultSemantics(
      movie.title,
      _year(movie),
      directedBy ?? '',
      action,
    );

    return Semantics(
      container: true,
      label: semanticsLabel,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onOpen();
        },
        onLongPress: onLongPressMenu == null
            ? null
            : () {
                HapticFeedback.mediumImpact();
                onLongPressMenu!();
              },
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(
            vertical: tokens.spaceXs,
            horizontal: tokens.spaceSm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _PosterThumb(movie: movie, heroTag: heroTag),
              SizedBox(width: tokens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                    ),
                    SizedBox(height: tokens.spaceXs),
                    Wrap(
                      spacing: tokens.spaceXs,
                      runSpacing: 0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _yearText(movie),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                        ),
                        if (directedBy != null) ...[
                          Text(
                            '· ${l10n.findDirectedBy.toLowerCase()}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                          ),
                          Text(
                            directedBy,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                          ),
                        ],
                      ],
                    ),
                    if (movie.genres.isNotEmpty) ...[
                      SizedBox(height: tokens.spaceXs),
                      _GenreChip(label: movie.genres.first),
                    ],
                  ],
                ),
              ),
              SizedBox(width: tokens.spaceMd),
              AddButton(
                added: added,
                processing: processing,
                semanticsLabel: addSemantics ?? '',
                onPressed: added ? null : onAdd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PosterThumb extends StatelessWidget {
  const _PosterThumb({required this.movie, this.heroTag});

  final Movie movie;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final width = 46.0;
    final height = width / tokens.posterAspectRatio;
    final url = movie.posterUrl;
    final thumb = ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radiusSm),
      child: SizedBox(
        width: width,
        height: height,
        child: url == null
            ? const _PosterThumbFallback()
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) => const _PosterThumbFallback(),
                errorWidget: (_, __, ___) => const _PosterThumbFallback(),
              ),
      ),
    );
    final tag = heroTag;
    if (tag == null) return thumb;
    return Hero(tag: tag, child: thumb);
  }
}

class _PosterThumbFallback extends StatelessWidget {
  const _PosterThumbFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.surfaceRaised,
      child: Center(
        child: Icon(Icons.movie_outlined, color: AppColors.textMuted),
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: tokens.spaceSm,
          vertical: 2,
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
}

String _year(Movie movie) => movie.year?.toString() ?? '';
String _yearText(Movie movie) => movie.year?.toString() ?? '—';
