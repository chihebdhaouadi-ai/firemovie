import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../bloc/home_screen_state.dart';
import '../../data/home_models.dart';
import 'add_tile.dart';
import 'film_tile.dart';
import 'section_status.dart';
import 'skeletons.dart';

class Top5Row extends StatelessWidget {
  const Top5Row({
    super.key,
    required this.title,
    required this.state,
    required this.onRetry,
    required this.onAddSlot,
    required this.onRemove,
  });

  final String title;
  final SectionState state;
  final VoidCallback onRetry;

  /// Invoked with the 1-based slot (1..5) when the user taps an empty slot.
  final ValueChanged<int> onAddSlot;
  final ValueChanged<Film> onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return switch (state) {
      SectionLoading() => SkeletonShimmer(
          child: _Top5Slots(
            title: title,
            films: const [],
            placeholder: true,
            onAddSlot: onAddSlot,
            onRemove: onRemove,
          ),
        ),
      SectionEmpty() => _Top5Slots(
          title: title,
          films: const [],
          placeholder: false,
          onAddSlot: onAddSlot,
          onRemove: onRemove,
        ),
      SectionError() => SectionStatusCard(
          message: l10n.homeSectionErrorTitle,
          actionIcon: Icons.refresh,
          actionLabel: l10n.homeSectionErrorRetry,
          onAction: onRetry,
        ),
      SectionContent(films: final films) => _Top5Slots(
          title: title,
          films: films,
          placeholder: false,
          onAddSlot: onAddSlot,
          onRemove: onRemove,
        ),
    };
  }
}

class _Top5Slots extends StatelessWidget {
  const _Top5Slots({
    required this.title,
    required this.films,
    required this.placeholder,
    required this.onAddSlot,
    required this.onRemove,
  });

  final String title;
  final List<Film> films;
  final bool placeholder;
  final ValueChanged<int> onAddSlot;
  final ValueChanged<Film> onRemove;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < HomeLimits.top5Slots; index++) ...[
          if (index > 0) SizedBox(width: tokens.topTileGap),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                if (index < films.length) {
                  final film = films[index];
                  return FilmTile(
                    film: film,
                    width: width,
                    semanticsLabel:
                        l10n.homeFilmTileSemantics(film.displayTitle, title),
                    removeLabel: l10n.homeRemoveFilm(film.displayTitle),
                    onRemove: () => onRemove(film),
                  );
                }
                if (placeholder) {
                  return const PosterSkeleton();
                }
                return AddTile(
                  width: width,
                  label: l10n.homeTop5AddLabel,
                  onTap: () => onAddSlot(index + 1),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
