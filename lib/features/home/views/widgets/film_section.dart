import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../bloc/home_screen_state.dart';
import '../../data/home_models.dart';
import 'add_tile.dart';
import 'film_tile.dart';
import 'section_header.dart';
import 'section_status.dart';
import 'skeletons.dart';

class FilmSection extends StatelessWidget {
  const FilmSection({
    super.key,
    required this.title,
    required this.state,
    required this.tileWidth,
    required this.onRetry,
    this.onAdd,
    this.onRemove,
    this.onTapFilm,
    this.selectedFilms = const {},
  });

  final String title;
  final SectionState state;
  final double tileWidth;
  final VoidCallback onRetry;
  final VoidCallback? onAdd;
  final ValueChanged<Film>? onRemove;
  final ValueChanged<Film>? onTapFilm;
  final Set<Film> selectedFilms;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final add = onAdd;

    final body = switch (state) {
      SectionLoading() => PosterSkeletonRow(tileWidth: tileWidth),
      SectionEmpty() => SectionStatusCard(
          message: l10n.homeSectionEmptyTitle,
          actionIcon: Icons.add,
          actionLabel: add == null ? null : l10n.homeSectionEmptyAction,
          onAction: add,
        ),
      SectionError() => SectionStatusCard(
          message: l10n.homeSectionErrorTitle,
          actionIcon: Icons.refresh,
          actionLabel: l10n.homeSectionErrorRetry,
          onAction: onRetry,
        ),
      SectionContent(films: final films) => _FilmRow(
          title: title,
          films: films,
          tileWidth: tileWidth,
          onAdd: add,
          onRemove: onRemove,
          onTapFilm: onTapFilm,
          selectedFilms: selectedFilms,
        ),
    };

    final trailing = switch (state) {
      SectionContent(films: final films) => l10n.homeFilmCount(films.length),
      _ => null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, trailing: trailing),
        body,
      ],
    );
  }
}

class _FilmRow extends StatelessWidget {
  const _FilmRow({
    required this.title,
    required this.films,
    required this.tileWidth,
    required this.onAdd,
    required this.onRemove,
    required this.onTapFilm,
    required this.selectedFilms,
  });

  final String title;
  final List<Film> films;
  final double tileWidth;
  final VoidCallback? onAdd;
  final ValueChanged<Film>? onRemove;
  final ValueChanged<Film>? onTapFilm;
  final Set<Film> selectedFilms;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final add = onAdd;
    final remove = onRemove;
    final tap = onTapFilm;
    final itemCount = add == null ? films.length : films.length + 1;

    return SizedBox(
      height: tokens.posterHeight(tileWidth),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (context, index) => SizedBox(width: tokens.spaceSm),
        itemBuilder: (context, index) {
          if (index == films.length && add != null) {
            return AddTile(
              width: tileWidth,
              label: l10n.homeAddTileLabel(title),
              onTap: add,
            );
          }
          final film = films[index];
          return FilmTile(
            film: film,
            width: tileWidth,
            semanticsLabel:
                l10n.homeFilmTileSemantics(film.displayTitle, title),
            removeLabel: l10n.homeRemoveFilm(film.displayTitle),
            selected: selectedFilms.contains(film),
            onTap: tap == null ? null : () => tap(film),
            onRemove: remove == null ? null : () => remove(film),
          );
        },
      ),
    );
  }
}
