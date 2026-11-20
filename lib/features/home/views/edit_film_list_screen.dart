import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/luxe_palette.dart';
import '../../find/data/movie.dart';
import '../../find/views/find_route_args.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_screen_event.dart';
import '../bloc/home_screen_state.dart';
import '../data/home_models.dart';
import 'home_navigation.dart';
import 'widgets/film_tile.dart';
import 'widgets/poster_lens_field.dart';

/// Opens the edit page for one of the home lists (Top 5, Watched,
/// Watchlist). The page shares the home bloc, so changes show on both.
void openEditFilmList(
  BuildContext context, {
  required HomeList list,
  required String title,
}) {
  final bloc = context.read<HomeBloc>();
  Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: EditFilmListScreen(list: list, title: title),
      ),
    ),
  );
}

/// Every film in a list as a poster grid, each with a remove button, and a
/// way to add more. Top 5 is numbered and adding stops at five. The ⋮ menu
/// shares the list, and on the Watchlist opens [RandomPickScreen].
class EditFilmListScreen extends StatelessWidget {
  const EditFilmListScreen({
    super.key,
    required this.list,
    required this.title,
    this.share = shareListText,
  });

  final HomeList list;
  final String title;

  /// Hands the list's text to the phone's share sheet; tests swap it.
  final Future<void> Function(String text) share;

  AddTarget get _target => switch (list) {
        HomeList.top5 => AddTarget.top5,
        HomeList.watched => AddTarget.watched,
        _ => AddTarget.watchlist,
      };

  List<Film> _filmsOf(HomeScreenState state) {
    final section = state is HomeLoaded ? state.sections[list] : null;
    return switch (section) {
      SectionContent(films: final films) => films,
      _ => const <Film>[],
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    return Scaffold(
      backgroundColor: LuxeColors.bg,
      appBar: AppBar(
        backgroundColor: LuxeColors.bg,
        surfaceTintColor: Colors.transparent,
        title: Text(l10n.homeEditList(title)),
        actions: [
          BlocBuilder<HomeBloc, HomeScreenState>(
            builder: (context, state) => _ListMenu(
              list: list,
              title: title,
              films: _filmsOf(state),
              share: share,
            ),
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeScreenState>(
        builder: (context, state) {
          final section = state is HomeLoaded ? state.sections[list] : null;
          final films = switch (section) {
            SectionContent(films: final films) => films,
            _ => const <Film>[],
          };
          if (section == null || section is SectionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final top5 = list == HomeList.top5;
          final full = top5 && films.length >= HomeLimits.top5Slots;
          void add() => openFind(
                context,
                args: FindFilmRouteArgs(
                  target: _target,
                  slot: top5 ? films.length + 1 : 0,
                ),
              );

          // The same poster grid as the browse pages.
          final grid = films.isEmpty
              ? Center(
                  child: Text(
                    l10n.homeEditListEmpty,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: LuxeColors.muted),
                  ),
                )
              : GridView.builder(
                  padding: EdgeInsets.all(tokens.spaceLg),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    // Covers at 60% of the browse grid's size.
                    maxCrossAxisExtent: 72,
                    mainAxisSpacing: tokens.spaceMd,
                    crossAxisSpacing: tokens.spaceMd,
                    childAspectRatio: 0.46,
                  ),
                  itemCount: films.length,
                  itemBuilder: (context, i) => _FilmTile(
                    key: ValueKey(films[i].imdbId),
                    film: films[i],
                    rank: top5 ? i + 1 : null,
                    onOpen: () => openOverview(context, films[i]),
                    onRemove: () => context
                        .read<HomeBloc>()
                        .add(HomeFilmRemoved(list, films[i])),
                  ),
                );

          return Column(
            children: [
              Expanded(child: grid),
              // Pinned to the bottom of the page.
              DecoratedBox(
                decoration: BoxDecoration(
                  color: LuxeColors.bg,
                  border: Border(top: BorderSide(color: LuxeColors.hair)),
                ),
                child: SafeArea(
                  top: false,
                  minimum: EdgeInsets.fromLTRB(
                    tokens.spaceLg,
                    tokens.spaceMd,
                    tokens.spaceLg,
                    tokens.spaceMd,
                  ),
                  child: full
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            l10n.homeEditListFull,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: LuxeColors.muted,
                              fontSize: 13,
                            ),
                          ),
                        )
                      : FilledButton.icon(
                          key: const Key('edit-list-add'),
                          onPressed: add,
                          icon: const Icon(BootstrapIcons.plus_lg, size: 16),
                          label: Text(l10n.homeEditListAdd),
                          style: FilledButton.styleFrom(
                            backgroundColor: LuxeColors.text,
                            foregroundColor: LuxeColors.bg,
                            minimumSize: const Size.fromHeight(52),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The phone's share sheet with plain text.
Future<void> shareListText(String text) async {
  await SharePlus.instance.share(ShareParams(text: text));
}

/// The text a shared list sends: a heading, then one film per line.
String listShareText(String heading, List<Film> films) => [
      heading,
      for (var i = 0; i < films.length; i++)
        '${i + 1}. ${films[i].displayTitle}',
    ].join('\n');

enum _ListAction { share, random }

/// The ⋮ menu: share the list, and on the Watchlist, pick a film at random.
class _ListMenu extends StatelessWidget {
  const _ListMenu({
    required this.list,
    required this.title,
    required this.films,
    required this.share,
  });

  final HomeList list;
  final String title;
  final List<Film> films;
  final Future<void> Function(String text) share;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopupMenuButton<_ListAction>(
      key: const Key('edit-list-menu'),
      tooltip: l10n.homeListMore,
      icon: Icon(BootstrapIcons.three_dots_vertical, color: LuxeColors.text),
      color: LuxeColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (action) => switch (action) {
        _ListAction.share =>
          share(listShareText(l10n.homeListShareText(title), films)),
        _ListAction.random => openRandomPick(context, list: list),
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          key: const Key('edit-list-share'),
          value: _ListAction.share,
          enabled: films.isNotEmpty,
          child: _MenuRow(
            icon: BootstrapIcons.box_arrow_up,
            label: l10n.homeListShare,
          ),
        ),
        if (list == HomeList.watchlist)
          PopupMenuItem(
            key: const Key('edit-list-random'),
            value: _ListAction.random,
            enabled: films.isNotEmpty,
            child: _MenuRow(
              icon: BootstrapIcons.shuffle,
              label: l10n.homeListRandom,
            ),
          ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: LuxeColors.text),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: LuxeColors.text)),
      ],
    );
  }
}

/// Opens the cover wall for [list]; it lands on a random film.
Future<void> openRandomPick(BuildContext context, {required HomeList list}) {
  final bloc = context.read<HomeBloc>();
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: RandomPickScreen(list: list),
      ),
    ),
  );
}

/// A wall of blurry covers that glides to a random film; drag to look
/// around, or ask for another.
class RandomPickScreen extends StatefulWidget {
  const RandomPickScreen({super.key, required this.list});

  final HomeList list;

  @override
  State<RandomPickScreen> createState() => _RandomPickScreenState();
}

class _RandomPickScreenState extends State<RandomPickScreen> {
  int _rolls = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: LuxeColors.bg,
      appBar: AppBar(
        backgroundColor: LuxeColors.bg,
        surfaceTintColor: Colors.transparent,
        title: Text(l10n.homeListRandom),
        actions: [
          IconButton(
            key: const Key('random-again'),
            tooltip: l10n.homeListShuffle,
            onPressed: () => setState(() => _rolls++),
            icon: Icon(BootstrapIcons.shuffle, color: LuxeColors.text),
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeScreenState>(
        builder: (context, state) {
          final section =
              state is HomeLoaded ? state.sections[widget.list] : null;
          final films = switch (section) {
            SectionContent(films: final films) => films,
            _ => const <Film>[],
          };
          if (films.isEmpty) {
            return Center(
              child: Text(
                l10n.homeEditListEmpty,
                style: TextStyle(color: LuxeColors.muted),
              ),
            );
          }
          return SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 12),
            child: PosterLensField(
              films: films,
              randomStart: true,
              rollSignal: _rolls,
              onOpen: (film) => openOverview(context, film),
              onRemove: (film) => context
                  .read<HomeBloc>()
                  .add(HomeFilmRemoved(widget.list, film)),
            ),
          );
        },
      ),
    );
  }
}

/// A poster with the title under it, like the browse grid, plus a remove
/// button on the poster's corner and the rank for Top 5.
class _FilmTile extends StatelessWidget {
  const _FilmTile({
    super.key,
    required this.film,
    required this.rank,
    required this.onOpen,
    required this.onRemove,
  });

  final Film film;
  final int? rank;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final name = film.title ?? film.imdbId;
    final rank = this.rank;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Every cover keeps the same 2:3 shape, whatever the title length.
        AspectRatio(
          aspectRatio: 2 / 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Semantics(
                button: true,
                label: name,
                child: GestureDetector(
                  onTap: onOpen,
                  child: LayoutBuilder(
                    builder: (context, box) => FilmPoster(
                      film: film,
                      width: box.maxWidth,
                      height: box.maxHeight,
                      radius: tokens.radiusMd,
                    ),
                  ),
                ),
              ),
              if (rank != null)
                PositionedDirectional(
                  start: 3,
                  top: 3,
                  child: _Badge(child: Text('$rank')),
                ),
              // The bin sits in the top corner; its tap area reaches a
              // little past the badge.
              PositionedDirectional(
                end: 0,
                top: 0,
                child: Tooltip(
                  message: l10n.homeEditListRemove(name),
                  child: Semantics(
                    button: true,
                    label: l10n.homeEditListRemove(name),
                    excludeSemantics: true,
                    child: GestureDetector(
                      key: Key('edit-list-remove-${film.imdbId}'),
                      behavior: HitTestBehavior.opaque,
                      onTap: onRemove,
                      child: const Padding(
                        padding: EdgeInsets.all(3),
                        child: _Badge(
                          child: Icon(BootstrapIcons.trash3, size: 11),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: LuxeColors.text,
            fontSize: 11,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: LuxeColors.bg.withValues(alpha: .9),
        shape: BoxShape.circle,
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: LuxeColors.text,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
        child: IconTheme.merge(
          data: IconThemeData(color: LuxeColors.text),
          child: child,
        ),
      ),
    );
  }
}
