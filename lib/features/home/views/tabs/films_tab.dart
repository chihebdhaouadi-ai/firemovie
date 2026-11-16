import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/sign_in_prompt.dart';
import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/scroll_exit_effect.dart';
import '../../../find/data/movie.dart';
import '../../../film_reviews/data/review_repository.dart';
import '../../../find/views/find_route_args.dart';
import '../../bloc/home_bloc.dart';
import '../../bloc/home_screen_event.dart';
import '../../bloc/home_screen_state.dart';
import '../../data/home_models.dart';
import '../home_navigation.dart';
import '../widgets/collections_box.dart';
import '../widgets/film_section.dart';
import '../widgets/section_header.dart';
import '../widgets/take_list_section.dart';
import '../widgets/top5_row.dart';

class FilmsTab extends StatelessWidget {
  const FilmsTab({
    super.key,
    required this.state,
    required this.exitInset,
    this.reviews,
    this.signedIn = true,
  });

  final HomeLoaded state;

  /// Pinned header height; sections blur and narrow once they pass it.
  final double exitInset;
  final ReviewRepository? reviews;

  /// Lists belong to an account, so guests see a sign-in prompt.
  final bool signedIn;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final bloc = context.read<HomeBloc>();
    final sections = state.sections;

    if (!signedIn) {
      return ScrollExitEffect(
        exitInset: exitInset,
        child: SignInPrompt(
          title: l10n.authGuestPromptTitle,
          body: l10n.authGuestPromptBody,
          reason: l10n.authReasonHome,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScrollExitEffect(
          exitInset: exitInset,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SectionHeader(
                title: l10n.homeTop5Title,
                trailing: l10n.homeTop5Hint,
              ),
              SizedBox(height: tokens.spaceSm),
              Top5Row(
                title: l10n.homeTop5Title,
                state: sections[HomeList.top5] ?? const SectionLoading(),
                onRetry: () =>
                    bloc.add(const HomeSectionRetryRequested(HomeList.top5)),
                onAddSlot: (slot) => openFind(
                  context,
                  args: FindFilmRouteArgs(target: AddTarget.top5, slot: slot),
                ),
                onOpenFilm: (film) => openOverview(context, film),
                onRemove: (film) =>
                    bloc.add(HomeFilmRemoved(HomeList.top5, film)),
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.spaceXl),
        ScrollExitEffect(
          exitInset: exitInset,
          child: CollectionsBox(
            title: l10n.homeCollectionsTitle,
            resizeLabel: l10n.homeCollectionsResizeLabel,
            children: [
              FilmSection(
                title: l10n.homeWatchedTitle,
                state: sections[HomeList.watched] ?? const SectionLoading(),
                tileWidth: tokens.filmTileWidth,
                onRetry: () => bloc
                    .add(const HomeSectionRetryRequested(HomeList.watched)),
                onAdd: () => openFind(
                  context,
                  args: const FindFilmRouteArgs(target: AddTarget.watched),
                ),
                onRemove: (film) =>
                    bloc.add(HomeFilmRemoved(HomeList.watched, film)),
                onOpenFilm: (film) => openOverview(context, film),
              ),
              SizedBox(height: tokens.spaceXl),
              FilmSection(
                title: l10n.homeWatchlistTitle,
                state: sections[HomeList.watchlist] ?? const SectionLoading(),
                tileWidth: tokens.filmTileWidth,
                onRetry: () => bloc
                    .add(const HomeSectionRetryRequested(HomeList.watchlist)),
                onAdd: () => openFind(
                  context,
                  args: const FindFilmRouteArgs(target: AddTarget.watchlist),
                ),
                onRemove: (film) =>
                    bloc.add(HomeFilmRemoved(HomeList.watchlist, film)),
                onOpenFilm: (film) => openOverview(context, film),
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.spaceXl),
        ScrollExitEffect(
          exitInset: exitInset,
          child: TakeListSection(
            title: l10n.homeMyTakesTitle,
            emptyMessage: l10n.homeMyTakesEmpty,
            load: (repository) => repository.fetchMyTakes(),
            reviews: reviews,
          ),
        ),
      ],
    );
  }
}
