import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/game_parts.dart';
import '../../../find/data/movie.dart';
import '../../../find/views/film_detail_screen.dart';
import '../../../popular/data/popular_film.dart';
import '../../../popular/data/popular_repository.dart';
import 'section_header.dart';
import 'section_status.dart';
import 'horizontal_scroll_hint.dart';

/// Films people added to watched or watchlist most this week.
class PopularThisWeekSection extends StatefulWidget {
  const PopularThisWeekSection(
      {super.key, required this.title, this.repository});

  final String title;
  final PopularRepository? repository;

  @override
  State<PopularThisWeekSection> createState() => _PopularThisWeekSectionState();
}

class _PopularThisWeekSectionState extends State<PopularThisWeekSection> {
  late Future<List<PopularFilm>> _films = _load();

  Future<List<PopularFilm>> _load() =>
      (widget.repository ?? ApiPopularRepository()).fetchThisWeek();

  void _retry() => setState(() => _films = _load());

  // Tracks horizontal scroll so each card can shrink as it nears the left edge.
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;

    return FutureBuilder<List<PopularFilm>>(
      future: _films,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: widget.title),
              SectionStatusCard(
                message: l10n.homeSectionErrorTitle,
                actionIcon: Icons.refresh,
                actionLabel: l10n.homeSectionErrorRetry,
                onAction: _retry,
              ),
            ],
          );
        }
        final films = snapshot.data;
        if (films == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: widget.title),
              const LinearProgressIndicator(
                color: AppColors.accentGlow,
                backgroundColor: AppColors.surfaceRaised,
              ),
            ],
          );
        }
        if (films.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: widget.title),
            SizedBox(height: tokens.spaceSm),
            HorizontalScrollHint(
              controller: _scroll,
              height: 180,
              child: ListView.separated(
                controller: _scroll,
                scrollDirection: Axis.horizontal,
                // Room for the poster lip and shadow.
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                itemCount: films.length,
                separatorBuilder: (_, __) => SizedBox(width: tokens.spaceMd),
                itemBuilder: (context, index) => _PopularFilmCard(
                  film: films[index],
                  index: index,
                  scrollController: _scroll,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PopularFilmCard extends StatelessWidget {
  const _PopularFilmCard({
    required this.film,
    required this.index,
    required this.scrollController,
  });

  final PopularFilm film;
  final int index;
  final ScrollController scrollController;

  static const _posterWidth = 90.0;
  static const _posterHeight = _posterWidth * 3 / 2;
  static const _minPosterHeight = 96.0;
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
    final poster = film.posterUrl;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);

    return SizedBox(
      width: _posterWidth,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FilmDetailScreen(
              movie: Movie(
                id: film.filmId,
                title: film.title,
                year: film.year,
                posterUrl: film.posterUrl,
              ),
            ),
          ),
        ),
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
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: GameColors.edge, width: 2),
                      boxShadow: [
                        const BoxShadow(
                          color: GameColors.edge,
                          offset: Offset(0, 5),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .4),
                          offset: const Offset(0, 9),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    // Gloss across the top of the poster.
                    foregroundDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
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
                          ? const ColoredBox(color: AppColors.surfaceRaised)
                          : CachedNetworkImage(
                              imageUrl: poster,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                              memCacheWidth:
                                  (_posterWidth * pixelRatio).round(),
                              memCacheHeight:
                                  (_posterHeight * pixelRatio).round(),
                              placeholder: (_, __) => const ColoredBox(
                                color: AppColors.surfaceRaised,
                              ),
                              errorWidget: (_, __, ___) => const ColoredBox(
                                color: AppColors.surfaceRaised,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              film.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppFonts.brand,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color.fromARGB(191, 255, 255, 255),
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
