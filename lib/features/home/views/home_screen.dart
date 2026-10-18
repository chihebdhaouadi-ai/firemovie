import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../find/data/movie.dart';
import '../../find/views/find_film_screen.dart';
import '../../find/views/find_route_args.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_screen_event.dart';
import '../bloc/home_screen_state.dart';
import '../data/home_models.dart';
import 'widgets/film_section.dart';
import 'widgets/generate_button.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/quick_actions_bar.dart';
import 'widgets/recommend_section.dart';
import 'widgets/section_header.dart';
import 'widgets/top5_row.dart';

const _loadingState = HomeLoaded(
  sections: {
    HomeList.top5: SectionLoading(),
    HomeList.watched: SectionLoading(),
    HomeList.watchlist: SectionLoading(),
    HomeList.popular: SectionLoading(),
  },
);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocListener<HomeBloc, HomeScreenState>(
          listenWhen: (previous, current) =>
              _noticeId(previous) != _noticeId(current),
          listener: (context, state) {
            if (state case HomeLoaded(notice: final notice?)) {
              _showNotice(context, notice);
            }
          },
          child: BlocBuilder<HomeBloc, HomeScreenState>(
            builder: (context, state) => switch (state) {
              HomeLoading() => const _HomeBody(state: _loadingState),
              HomeLoaded loaded => _HomeBody(state: loaded),
            },
          ),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.state});

  final HomeLoaded state;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final bloc = context.read<HomeBloc>();
    final sections = state.sections;
    final picks = state.picks;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
        child: RefreshIndicator(
          onRefresh: () => _refresh(context),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: tokens.spaceLg,
              vertical: tokens.spaceLg,
            ),
            children: [
              HomeAppBar(points: state.points),
              SizedBox(height: tokens.spaceXl),
              QuickActionsBar(
                onSearch: () => _openFind(context),
                onAddFilm: () => _openFind(context),
              ),
              SizedBox(height: tokens.spaceXl),
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
                onAddSlot: (slot) => _openFind(
                  context,
                  args: FindFilmRouteArgs(target: AddTarget.top5, slot: slot),
                ),
                onRemove: (film) =>
                    bloc.add(HomeFilmRemoved(HomeList.top5, film)),
              ),
              SizedBox(height: tokens.spaceXl),
              SectionHeader(title: l10n.homeRecommendTitle),
              SizedBox(height: tokens.spaceSm),
              RecommendSection(
                picks: picks,
                onRemovePick: (film) => bloc.add(HomePickToggled(film)),
                onAddPick: (index) => _openFind(
                  context,
                  args: FindFilmRouteArgs(
                    target: AddTarget.generatePick,
                    pickIndex: index,
                  ),
                ),
              ),
              SizedBox(height: tokens.spaceLg),
              GenerateButton(
                enabled: state.canGenerate,
                generating: state.generating,
                remaining: HomeLimits.recommendPicks - picks.length,
                onPressed: () => bloc.add(const HomeGenerateRequested()),
              ),
              SizedBox(height: tokens.spaceXl),
              FilmSection(
                title: l10n.homeWatchedTitle,
                state: sections[HomeList.watched] ?? const SectionLoading(),
                tileWidth: tokens.filmTileWidth,
                onRetry: () =>
                    bloc.add(const HomeSectionRetryRequested(HomeList.watched)),
                onAdd: () => _openFind(
                  context,
                  args: const FindFilmRouteArgs(target: AddTarget.watched),
                ),
                onRemove: (film) =>
                    bloc.add(HomeFilmRemoved(HomeList.watched, film)),
                onTapFilm: (film) => bloc.add(HomePickToggled(film)),
                selectedFilms: picks.toSet(),
              ),
              SizedBox(height: tokens.spaceXl),
              FilmSection(
                title: l10n.homeWatchlistTitle,
                state: sections[HomeList.watchlist] ?? const SectionLoading(),
                tileWidth: tokens.filmTileWidth,
                onRetry: () => bloc
                    .add(const HomeSectionRetryRequested(HomeList.watchlist)),
                onAdd: () => _openFind(
                  context,
                  args: const FindFilmRouteArgs(target: AddTarget.watchlist),
                ),
                onRemove: (film) =>
                    bloc.add(HomeFilmRemoved(HomeList.watchlist, film)),
              ),
              SizedBox(height: tokens.spaceXl),
              FilmSection(
                title: l10n.homePopularTitle,
                state: sections[HomeList.popular] ?? const SectionLoading(),
                tileWidth: tokens.filmTileWidth,
                onRetry: () =>
                    bloc.add(const HomeSectionRetryRequested(HomeList.popular)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

int? _noticeId(HomeScreenState state) => switch (state) {
      HomeLoaded(:final notice) => notice?.id,
      HomeLoading() => null,
    };

Future<void> _refresh(BuildContext context) {
  final bloc = context.read<HomeBloc>();
  final done = Completer<void>();
  bloc.add(HomeRefreshRequested(done: done));
  return done.future;
}

Future<void> _openFind(
  BuildContext context, {
  FindFilmRouteArgs args = const FindFilmRouteArgs(),
}) async {
  final bloc = context.read<HomeBloc>();
  final result = await Navigator.of(context).push<FindFilmResult>(
    FindFilmScreen.route(args),
  );
  if (!context.mounted) return;

  final film = result?.film;
  final target = result?.target;

  if (film == null || target == null) {
    // Reflect any activity that may have happened in the find screen.
    bloc.add(const HomeRefreshRequested());
    return;
  }

  switch (target) {
    case AddTarget.top5:
      final homeFilm =
          Film(imdbId: film.id, title: film.title, posterUrl: film.posterUrl);
      bloc.add(HomeFilmAdded(HomeList.top5, homeFilm));
      bloc.add(HomeSectionRetryRequested(HomeList.top5));
    case AddTarget.watched:
      final homeFilm =
          Film(imdbId: film.id, title: film.title, posterUrl: film.posterUrl);
      bloc.add(HomeFilmAdded(HomeList.watched, homeFilm));
      bloc.add(HomeSectionRetryRequested(HomeList.watched));
    case AddTarget.watchlist:
      final homeFilm =
          Film(imdbId: film.id, title: film.title, posterUrl: film.posterUrl);
      bloc.add(HomeFilmAdded(HomeList.watchlist, homeFilm));
      bloc.add(HomeSectionRetryRequested(HomeList.watchlist));
    case AddTarget.generatePick:
      final homeFilm =
          Film(imdbId: film.id, title: film.title, posterUrl: film.posterUrl);
      if (bloc.state is HomeLoaded) {
        bloc.add(HomePickToggled(homeFilm));
      }
  }
}

void _showNotice(BuildContext context, HomeNotice notice) {
  final l10n = context.l10n;
  final bloc = context.read<HomeBloc>();

  final message = switch (notice) {
    FilmRemovedNotice(:final film) =>
      l10n.homeRemovedSnackbar(film.displayTitle),
    Top5FullNotice() => l10n.homeTop5FullSnackbar,
    PicksFullNotice() => l10n.homeRecommendFullSnackbar,
    RecommendReadyNotice() => l10n.homeGenerateSuccess,
    ActionFailedNotice() => l10n.homeGenericErrorSnackbar,
  };

  final action = switch (notice) {
    FilmRemovedNotice(:final list, :final film, :final index) => SnackBarAction(
        label: l10n.homeUndo,
        onPressed: () => bloc.add(HomeFilmRestored(list, film, index)),
      ),
    _ => null,
  };

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), action: action));
}
