import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../find/data/movie.dart';
import '../../../find/views/film_detail_screen.dart';
import '../../../popular/data/popular_film.dart';
import '../../../popular/data/popular_repository.dart';
import 'section_header.dart';
import 'shelf_poster_card.dart';
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

  @override
  Widget build(BuildContext context) {
    return ShelfPosterCard(
      title: film.title,
      posterUrl: film.posterUrl,
      index: index,
      scrollController: scrollController,
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
    );
  }
}
