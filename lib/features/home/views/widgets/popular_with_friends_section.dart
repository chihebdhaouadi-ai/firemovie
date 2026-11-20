import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../bloc/home_screen_state.dart';
import '../../data/home_models.dart';
import 'horizontal_scroll_hint.dart';
import 'section_header.dart';
import 'section_status.dart';
import 'shelf_poster_card.dart';

/// Films popular with the user's friends, shown like Popular Films: framed
/// covers with their titles under them.
class PopularWithFriendsSection extends StatefulWidget {
  const PopularWithFriendsSection({
    super.key,
    required this.title,
    required this.state,
    required this.onRetry,
    required this.onOpenFilm,
  });

  final String title;
  final SectionState state;
  final VoidCallback onRetry;
  final ValueChanged<Film> onOpenFilm;

  @override
  State<PopularWithFriendsSection> createState() =>
      _PopularWithFriendsSectionState();
}

class _PopularWithFriendsSectionState extends State<PopularWithFriendsSection> {
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

    final body = switch (widget.state) {
      SectionLoading() => LinearProgressIndicator(
          color: AppColors.accentGlow,
          backgroundColor: AppColors.surfaceRaised,
        ),
      SectionError() => SectionStatusCard(
          message: l10n.homeSectionErrorTitle,
          actionIcon: BootstrapIcons.arrow_clockwise,
          actionLabel: l10n.homeSectionErrorRetry,
          onAction: widget.onRetry,
        ),
      SectionEmpty() => null,
      SectionContent(films: final films) => Padding(
          padding: const EdgeInsets.only(top: SectionHeader.contentGap),
          child: HorizontalScrollHint(
            controller: _scroll,
            height: ShelfPosterCard.rowHeight,
            child: ListView.separated(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              itemCount: films.length,
              separatorBuilder: (_, __) => SizedBox(width: tokens.spaceMd),
              itemBuilder: (context, index) {
                final film = films[index];
                return ShelfPosterCard(
                  title: film.displayTitle,
                  posterUrl: film.posterUrl,
                  index: index,
                  scrollController: _scroll,
                  onTap: () => widget.onOpenFilm(film),
                );
              },
            ),
          ),
        ),
    };
    if (body == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: widget.title),
        body,
      ],
    );
  }
}
