import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/game_parts.dart';
import 'film_tile.dart';

/// A film cover on a home shelf (Popular Films, Popular with Friends): a
/// framed poster with a lip and gloss, the title under it, shrinking as it
/// slides past the left edge of its list.
class ShelfPosterCard extends StatelessWidget {
  const ShelfPosterCard({
    super.key,
    required this.title,
    required this.posterUrl,
    required this.index,
    required this.scrollController,
    required this.onTap,
  });

  final String title;
  final String? posterUrl;

  /// Position in the list, used to work out the shrink near the left edge.
  final int index;
  final ScrollController scrollController;
  final VoidCallback onTap;

  /// Height of a shelf row: poster and two lines of title, with just
  /// enough room left for the poster's lip and shadow.
  static const rowHeight = 106.0;

  // 40% smaller than the original 90 px covers.
  static const _posterWidth = 54.0;
  static const _posterHeight = _posterWidth * 3 / 2;
  static const _minPosterHeight = 58.0;
  // How far past the left edge the card must travel before it reaches the
  // minimum height. Cards fully inside the list keep their full height.
  static const _shrinkZone = _posterWidth;

  /// Poster height for this card. It stays full height while the card is
  /// inside the list, and shrinks once its left edge goes past the left side.
  double _posterHeightFor(double gap) {
    final offset = scrollController.hasClients ? scrollController.offset : 0.0;
    final distanceFromLeft = index * (_posterWidth + gap) - offset;
    final overshoot = (-distanceFromLeft / _shrinkZone).clamp(0.0, 1.0);
    return _posterHeight - (_posterHeight - _minPosterHeight) * overshoot;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final poster = posterUrl;

    return SizedBox(
      width: _posterWidth,
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListenableBuilder(
              listenable: scrollController,
              builder: (context, child) => SizedBox(
                width: _posterWidth,
                height: _posterHeight,
                child: Transform.scale(
                  scale: _posterHeightFor(tokens.spaceMd) / _posterHeight,
                  child: child,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: GameColors.panel,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: GameColors.edge, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: GameColors.edge,
                          offset: Offset(0, 3),
                        ),
                        BoxShadow(
                          color: themed(Colors.black.withValues(alpha: .4),
                              const Color(0x221A1814)),
                          offset: const Offset(0, 6),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    // Gloss across the top of the poster.
                    foregroundDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: const Alignment(0, -.4),
                        colors: [
                          Colors.white.withValues(alpha: .22),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: poster == null || poster.isEmpty
                          ? ColoredBox(color: AppColors.surfaceRaised)
                          : PosterImage(
                              url: poster,
                              width: _posterWidth,
                              height: _posterHeight,
                            ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppFonts.brand,
                fontSize: 8,
                fontWeight: FontWeight.w400,
                color: themed(const Color.fromARGB(191, 255, 255, 255),
                    const Color(0xFF36322B)),
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
