import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/widgets/luxe_palette.dart';
import '../../../home/views/widgets/film_tile.dart';
import '../../data/movie_list.dart';

/// Width of a list card in a row.
const double movieListCardWidth = 200;

/// A posted list: its posters stacked like cards fanned to the right, the
/// list's name, and its hearts and comments.
class MovieListCard extends StatelessWidget {
  const MovieListCard({super.key, required this.list, required this.onTap});

  final MovieList list;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      button: true,
      label: '${list.name}, ${l10n.listFilmCount(list.filmCount)}',
      excludeSemantics: true,
      child: GestureDetector(
        key: Key('movie-list-${list.id}'),
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: movieListCardWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StackedPosters(posters: list.posters, height: 170),
              const SizedBox(height: 10),
              Text(
                list.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: LuxeColors.text,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    list.liked
                        ? BootstrapIcons.heart_fill
                        : BootstrapIcons.heart,
                    size: 14,
                    color:
                        list.liked ? const Color(0xFFD6334F) : LuxeColors.muted,
                  ),
                  const SizedBox(width: 5),
                  _Count('${list.likes}'),
                  const SizedBox(width: 14),
                  Icon(BootstrapIcons.chat, size: 14, color: LuxeColors.muted),
                  const SizedBox(width: 5),
                  _Count('${list.comments}'),
                  const Spacer(),
                  _Count(l10n.listFilmCount(list.filmCount)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          color: LuxeColors.muted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      );
}

/// Up to four posters as a fanned stack: the first in front, the others
/// peeking out behind it to the right, each a little shorter.
class StackedPosters extends StatelessWidget {
  const StackedPosters(
      {super.key, required this.posters, required this.height});

  final List<String> posters;
  final double height;

  @override
  Widget build(BuildContext context) {
    final front = height * 2 / 3;
    const peek = 16.0;
    final count = posters.isEmpty ? 1 : posters.length.clamp(1, 4);
    return SizedBox(
      height: height,
      width: front + peek * 3,
      child: Stack(
        children: [
          for (var i = count - 1; i >= 0; i--)
            Positioned(
              left: peek * i,
              top: 6.0 * i,
              bottom: 6.0 * i,
              width: front,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .22),
                      blurRadius: 10,
                      offset: const Offset(-3, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ColorFiltered(
                    // The ones behind are a touch darker.
                    colorFilter: ColorFilter.mode(
                      Colors.black.withValues(alpha: i * .12),
                      BlendMode.srcATop,
                    ),
                    child: posters.isEmpty
                        ? const PosterPlaceholder()
                        : PosterImage(
                            url: posters[i],
                            width: front,
                            height: height - 12.0 * i,
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
