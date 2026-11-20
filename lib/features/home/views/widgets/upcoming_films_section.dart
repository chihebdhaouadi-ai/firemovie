import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/game_parts.dart';
import '../../../upcoming/data/upcoming_film.dart';
import '../../../upcoming/data/upcoming_repository.dart';
import 'section_header.dart';
import 'shelf_poster_card.dart';
import 'section_status.dart';
import 'horizontal_scroll_hint.dart';

/// Films that are not out yet. Tapping a poster says when the film releases.
class UpcomingFilmsSection extends StatefulWidget {
  const UpcomingFilmsSection({super.key, required this.title, this.repository});

  final String title;
  final UpcomingRepository? repository;

  @override
  State<UpcomingFilmsSection> createState() => _UpcomingFilmsSectionState();
}

class _UpcomingFilmsSectionState extends State<UpcomingFilmsSection> {
  late Future<List<UpcomingFilm>> _films = _load();
  final _scroll = ScrollController();

  Future<List<UpcomingFilm>> _load() =>
      (widget.repository ?? ApiUpcomingRepository()).fetchUpcoming();

  void _retry() => setState(() => _films = _load());

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onPosterTap(UpcomingFilm film) {
    final l10n = context.l10n;
    final date = MaterialLocalizations.of(context).formatMediumDate(
      film.releaseDate,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.upcomingNotOutYet(film.title, date))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;

    return FutureBuilder<List<UpcomingFilm>>(
      future: _films,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: widget.title),
              SectionStatusCard(
                message: l10n.homeSectionErrorTitle,
                actionIcon: BootstrapIcons.arrow_clockwise,
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
              LinearProgressIndicator(
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
            const SizedBox(height: SectionHeader.contentGap),
            HorizontalScrollHint(
              controller: _scroll,
              height: ShelfPosterCard.rowHeight,
              child: ListView.separated(
                controller: _scroll,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: films.length,
                separatorBuilder: (_, __) => SizedBox(width: tokens.spaceMd),
                itemBuilder: (context, index) => _UpcomingFilmCard(
                  film: films[index],
                  index: index,
                  scrollController: _scroll,
                  onTap: () => _onPosterTap(films[index]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _UpcomingFilmCard extends StatelessWidget {
  const _UpcomingFilmCard({
    required this.film,
    required this.index,
    required this.scrollController,
    required this.onTap,
  });

  final UpcomingFilm film;
  final int index;
  final ScrollController scrollController;
  final VoidCallback onTap;

  // 40% smaller than the original 90 px covers.
  static const _posterWidth = 54.0;
  static const _posterHeight = _posterWidth * 3 / 2;
  static const _minPosterHeight = 58.0;
  static const _shrinkZone = _posterWidth;

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
                      child: poster.isEmpty
                          ? ColoredBox(color: AppColors.surfaceRaised)
                          : CachedNetworkImage(
                              imageUrl: poster,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                              memCacheWidth:
                                  (_posterWidth * pixelRatio).round(),
                              memCacheHeight:
                                  (_posterHeight * pixelRatio).round(),
                              placeholder: (_, __) => ColoredBox(
                                color: AppColors.surfaceRaised,
                              ),
                              errorWidget: (_, __, ___) => ColoredBox(
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
