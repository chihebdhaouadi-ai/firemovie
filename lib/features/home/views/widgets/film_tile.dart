import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/home_models.dart';

class FilmPoster extends StatelessWidget {
  const FilmPoster({
    super.key,
    required this.film,
    required this.width,
    this.heroTag,
    this.selected = false,
  });

  final Film film;
  final double width;
  final Object? heroTag;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final height = tokens.posterHeight(width);
    final url = film.posterUrl;
    final heroTagValue = heroTag;

    final poster = ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radiusMd),
      child: SizedBox(
        width: width,
        height: height,
        child: url == null
            ? const PosterPlaceholder()
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (ctx, url) => const PosterPlaceholder(),
                errorWidget: (ctx, url, error) => const PosterPlaceholder(),
              ),
      ),
    );

    final framed = AnimatedContainer(
      duration: context.motion(tokens.durationBase),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        boxShadow: selected ? tokens.glowShadow : const [],
        border: Border.all(
          color: selected ? AppColors.accentGlow : AppColors.transparent,
          width: 1,
        ),
      ),
      child: poster,
    );

    if (heroTagValue == null) return framed;
    return Hero(tag: heroTagValue, child: framed);
  }
}

class PosterPlaceholder extends StatelessWidget {
  const PosterPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceRaised,
      child: Center(
        child: Icon(
          Icons.movie_outlined,
          color: AppColors.textMuted,
          size: context.tokens.iconLarge,
        ),
      ),
    );
  }
}

class FilmTile extends StatelessWidget {
  const FilmTile({
    super.key,
    required this.film,
    required this.width,
    required this.semanticsLabel,
    required this.removeLabel,
    this.heroTag,
    this.selected = false,
    this.onTap,
    this.onRemove,
  });

  final Film film;
  final double width;
  final String semanticsLabel;
  final String removeLabel;
  final Object? heroTag;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final tap = onTap;
    final remove = onRemove;

    return Semantics(
      button: tap != null,
      selected: selected,
      label: semanticsLabel,
      child: SizedBox(
        width: width,
        child: Stack(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              onTap: tap == null
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      tap();
                    },
              child: ExcludeSemantics(
                child: FilmPoster(
                  film: film,
                  width: width,
                  heroTag: heroTag,
                  selected: selected,
                ),
              ),
            ),
            if (remove != null)
              PositionedDirectional(
                top: 0,
                end: 0,
                child: IconButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    remove();
                  },
                  constraints: BoxConstraints.tightFor(
                    width: tokens.minTouchTarget,
                    height: tokens.minTouchTarget,
                  ),
                  icon: Container(
                    padding: EdgeInsets.all(tokens.spaceXs),
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: tokens.iconSmall,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  tooltip: removeLabel,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
