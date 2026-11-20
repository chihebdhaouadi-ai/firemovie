import 'dart:ui' show ImageFilter;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/luxe_palette.dart';
import '../../../home/data/home_models.dart';
import '../../../home/views/widgets/film_tile.dart';

/// Height of the cover band behind the top of a take's page.
const takeCoverHeight = 300.0;

/// The film's art behind the top of a take's page: the backdrop (or the
/// poster, blurred) fading into the page colour, so the take card seems to
/// rise out of the film.
class TakeCoverBackdrop extends StatelessWidget {
  const TakeCoverBackdrop({super.key, required this.film, this.backdropUrl});

  final Film film;
  final String? backdropUrl;

  @override
  Widget build(BuildContext context) {
    final backdrop = backdropUrl;
    final url = backdrop ?? film.posterUrl;
    // A wide backdrop reads well as is; a tall poster becomes a soft wash.
    final blur = backdrop == null ? 22.0 : 2.0;

    return ExcludeSemantics(
      child: IgnorePointer(
        // The blur would otherwise spill past the band's bottom edge.
        child: ClipRect(
          child: SizedBox(
            height: takeCoverHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (url != null)
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorWidget: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0, .35, 1],
                      // Light mode washes the cover with paper instead of
                      // shade, so the ink title above it stays readable.
                      colors: [
                        themed(
                            const Color(0x99000000), const Color(0x99F2EEE6)),
                        themed(
                            const Color(0x590A0B10), const Color(0xB3F2EEE6)),
                        LuxeColors.bg,
                      ],
                    ),
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

/// The film the take is about, sitting on the cover: poster and title.
class TakeCoverTitle extends StatelessWidget {
  const TakeCoverTitle({super.key, required this.film, this.year});

  final Film film;
  final int? year;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final year = this.year;

    return Semantics(
      container: true,
      label: '${l10n.topicAboutFilm}: ${film.displayTitle}',
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x99000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: FilmPoster(film: film, width: 72, height: 108, radius: 10),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.topicAboutFilm.toUpperCase(),
                    style: TextStyle(
                      color: LuxeColors.accentHi,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    film.displayTitle,
                    maxLines: 2,
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                      color: LuxeColors.text,
                      fontSize: 24,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      shadows: [
                        Shadow(
                          color: themed(
                              const Color(0xB3000000), const Color(0x99F2EEE6)),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                  if (year != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '$year',
                      style: TextStyle(
                        color: LuxeColors.muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// What a take's page needs to show its film's cover.
class TakeCoverInfo {
  const TakeCoverInfo({required this.film, this.backdropUrl, this.year});

  final Film film;
  final String? backdropUrl;
  final int? year;
}
