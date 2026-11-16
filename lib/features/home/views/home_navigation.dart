import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/auth/auth_gate.dart';
import '../../../core/l10n_context.dart';
import '../../find/data/movie.dart';
import '../../find/views/find_film_screen.dart';
import '../../find/views/find_route_args.dart';
import '../../overview/views/movie_overview_screen.dart';
import '../../profile/views/profile_screen.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_screen_event.dart';
import '../data/home_models.dart';

/// Each opener below is gated: a guest is sent to login first, and the page
/// opens only after a successful sign-in. Signed-in people go straight there.
void openProfile(BuildContext context) {
  unawaited(requireAuth(
    context,
    reason: context.l10n.authReasonProfile,
    action: () async {
      if (!context.mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
      );
    },
  ));
}

/// Film details and search are open to guests. Adding a film still asks for
/// login (see FindFilmScreen), and so do the account-only pages.
void openOverview(BuildContext context, Film film) {
  unawaited(Navigator.of(context).push<void>(
    MaterialPageRoute<void>(builder: (_) => MovieOverviewScreen(film: film)),
  ));
}

Future<void> openFind(
  BuildContext context, {
  FindFilmRouteArgs args = const FindFilmRouteArgs(),
}) {
  return _pushFind(context, args);
}

Future<void> _pushFind(BuildContext context, FindFilmRouteArgs args) async {
  final bloc = context.read<HomeBloc>();
  final result = await Navigator.of(context).push<FindFilmResult>(
    FindFilmScreen.route(args),
  );
  if (!context.mounted) return;

  final film = result?.film;
  final target = result?.target;

  if (film == null || target == null) {
    bloc.add(const HomeRefreshRequested());
    return;
  }

  final homeFilm =
      Film(imdbId: film.id, title: film.title, posterUrl: film.posterUrl);
  switch (target) {
    case AddTarget.top5:
      bloc.add(HomeFilmAdded(HomeList.top5, homeFilm));
      bloc.add(HomeSectionRetryRequested(HomeList.top5));
    case AddTarget.watched:
      bloc.add(HomeFilmAdded(HomeList.watched, homeFilm));
      bloc.add(HomeSectionRetryRequested(HomeList.watched));
    case AddTarget.watchlist:
      bloc.add(HomeFilmAdded(HomeList.watchlist, homeFilm));
      bloc.add(HomeSectionRetryRequested(HomeList.watchlist));
  }
}
