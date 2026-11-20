import 'package:bootstrap_icons/bootstrap_icons.dart';
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
    this.onOpenFilm,
    this.onEdit,
    this.subtitle,
  });

  final String title;
  final SectionState state;
  final double tileWidth;
  final VoidCallback onRetry;
  final VoidCallback? onAdd;
  final ValueChanged<Film>? onRemove;
  final ValueChanged<Film>? onOpenFilm;

  /// Opens the list's edit page from the pen beside the title.
  final VoidCallback? onEdit;

  /// A small line under the title; the film count follows it.
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final add = onAdd;

    final body = switch (state) {
      SectionLoading() => PosterSkeletonRow(tileWidth: tileWidth),
      SectionEmpty() => SectionStatusCard(
          message: l10n.homeSectionEmptyTitle,
          actionIcon: BootstrapIcons.plus_lg,
          actionLabel: add == null ? null : l10n.homeSectionEmptyAction,
          onAction: add,
        ),
      SectionError() => SectionStatusCard(
          message: l10n.homeSectionErrorTitle,
          actionIcon: BootstrapIcons.arrow_clockwise,
          actionLabel: l10n.homeSectionErrorRetry,
          onAction: onRetry,
        ),
      SectionContent(films: final films) => _FilmRow(
          title: title,
          films: films,
          tileWidth: tileWidth,
          onAdd: add,
          onRemove: onRemove,
          onOpenFilm: onOpenFilm,
        ),
    };

    final trailing = switch (state) {
      SectionContent(films: final films) => l10n.homeFilmCount(films.length),
      _ => null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          subtitle: subtitle == null
              ? null
              : [subtitle!, if (trailing != null) trailing].join(' · '),
          trailing: subtitle == null ? trailing : null,
          onEdit: onEdit,
          editLabel: l10n.homeEditList(title),
        ),
        // Same gap under the header as Your Top 5.
        SizedBox(height: context.tokens.spaceSm),
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
    required this.onOpenFilm,
  });

  final String title;
  final List<Film> films;
  final double tileWidth;
  final VoidCallback? onAdd;
  final ValueChanged<Film>? onRemove;
  final ValueChanged<Film>? onOpenFilm;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final add = onAdd;
    final remove = onRemove;
    final open = onOpenFilm;
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
            onTap: open == null ? null : () => open(film),
            onRemove: remove == null ? null : () => remove(film),
          );
        },
      ),
    );
  }
}
