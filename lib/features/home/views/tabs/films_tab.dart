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
import '../../../movie_lists/data/movie_list_repository.dart';
import '../../../movie_lists/presentation/widgets/movie_lists_section.dart';
import '../edit_film_list_screen.dart';
import '../home_navigation.dart';
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
    this.movieLists,
  });

  final HomeLoaded state;

  /// Pinned header height; sections blur and narrow once they pass it.
  final ExitInset exitInset;
  final ReviewRepository? reviews;

  /// Lists belong to an account, so guests see a sign-in prompt.
  final bool signedIn;

  /// Where "My lists" loads from; the real API when left out.
  final MovieListRepository? movieLists;

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
                subtitle: l10n.homeTop5Hint,
                onEdit: () => openEditFilmList(
                  context,
                  list: HomeList.top5,
                  title: l10n.homeTop5Title,
                ),
                editLabel: l10n.homeEditList(l10n.homeTop5Title),
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
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.spaceXl),
        // Watched and Watchlist are plain sections, like Your Top 5.
        ScrollExitEffect(
          exitInset: exitInset,
          child: FilmSection(
            title: l10n.homeWatchedTitle,
            subtitle: l10n.homeWatchedHint,
            state: sections[HomeList.watched] ?? const SectionLoading(),
            tileWidth: tokens.filmTileWidth,
            onRetry: () =>
                bloc.add(const HomeSectionRetryRequested(HomeList.watched)),
            onAdd: () => openFind(
              context,
              args: const FindFilmRouteArgs(target: AddTarget.watched),
            ),
            onOpenFilm: (film) => openOverview(context, film),
            onEdit: () => openEditFilmList(
              context,
              list: HomeList.watched,
              title: l10n.homeWatchedTitle,
            ),
          ),
        ),
        SizedBox(height: tokens.spaceXl),
        ScrollExitEffect(
          exitInset: exitInset,
          child: FilmSection(
            title: l10n.homeWatchlistTitle,
            subtitle: l10n.homeWatchlistHint,
            state: sections[HomeList.watchlist] ?? const SectionLoading(),
            tileWidth: tokens.filmTileWidth,
            onRetry: () =>
                bloc.add(const HomeSectionRetryRequested(HomeList.watchlist)),
            onAdd: () => openFind(
              context,
              args: const FindFilmRouteArgs(target: AddTarget.watchlist),
            ),
            onOpenFilm: (film) => openOverview(context, film),
            onEdit: () => openEditFilmList(
              context,
              list: HomeList.watchlist,
              title: l10n.homeWatchlistTitle,
            ),
          ),
        ),
        SizedBox(height: tokens.spaceXl),
        // Lists you made and posted, after your Watchlist.
        ScrollExitEffect(
          exitInset: exitInset,
          child: MovieListsSection(
            owner: MovieListsOwner.mine,
            repository: movieLists,
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
