import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/home/bloc/home_bloc.dart';
import 'package:film_wise_mobile/features/home/bloc/home_screen_event.dart';
import 'package:film_wise_mobile/features/home/bloc/home_screen_state.dart';
import 'package:film_wise_mobile/features/home/data/home_models.dart';
import 'package:film_wise_mobile/features/home/data/home_repository.dart';
import 'package:film_wise_mobile/features/home/views/edit_film_list_screen.dart';
import 'package:film_wise_mobile/features/home/views/tabs/films_tab.dart';
import 'package:film_wise_mobile/features/movie_lists/data/movie_list_repository.dart';
import 'package:film_wise_mobile/features/home/views/widgets/collections_box.dart';
import 'package:film_wise_mobile/features/home/views/widgets/film_section.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

final _en = lookupAppLocalizations(const Locale('en'));

void main() {
  testWidgets(
      'Collections shows Top 5, then Watched and Watchlist as plain '
      'sections without a box', (tester) async {
    final bloc = HomeBloc(
      repository: FakeHomeRepository(),
      gateway: FakePointsGateway(),
    );
    addTearDown(bloc.close);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider.value(
        value: bloc,
        child: Scaffold(
          body: SingleChildScrollView(
            child: FilmsTab(
              movieLists: FakeMovieListRepository(),
              exitInset: (_) => 0,
              state: const HomeLoaded(sections: {
                HomeList.top5: SectionContent([]),
                HomeList.watched: SectionContent([]),
                HomeList.watchlist: SectionContent([]),
              }),
            ),
          ),
        ),
      ),
    ));

    expect(find.byType(CollectionsBox), findsNothing);
    expect(find.text(_en.homeCollectionsTitle), findsNothing);
    expect(find.byType(FilmSection), findsNWidgets(2));
    final top5 = tester.getTopLeft(find.text(_en.homeTop5Title)).dy;
    final watched = tester.getTopLeft(find.text(_en.homeWatchedTitle)).dy;
    final watchlist = tester.getTopLeft(find.text(_en.homeWatchlistTitle)).dy;
    expect(top5 < watched && watched < watchlist, isTrue);
  });

  testWidgets('each list has a pen that opens its edit page', (tester) async {
    final bloc = HomeBloc(
      repository: FakeHomeRepository(),
      gateway: FakePointsGateway(),
    )..add(const HomeStarted());
    addTearDown(bloc.close);
    await _pumpTab(tester, bloc);

    expect(find.byKey(const Key('section-edit')), findsNWidgets(3));
    // Each title has its small line under it, and the pen is at the far end.
    for (final hint in [
      _en.homeTop5Hint,
      _en.homeWatchedHint,
      _en.homeWatchlistHint,
    ]) {
      expect(find.textContaining(hint), findsOneWidget);
    }
    final pen = tester.getTopRight(find.byKey(const Key('section-edit')).first);
    expect(pen.dx, closeTo(800, 1));
    expect(
      find.bySemanticsLabel(_en.homeEditList(_en.homeWatchlistTitle)),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('section-edit')).at(1));
    await tester.pumpAndSettle();
    expect(find.byType(EditFilmListScreen), findsOneWidget);
    expect(find.text(_en.homeEditList(_en.homeWatchedTitle)), findsOneWidget);
  });

  testWidgets(
      'the edit page numbers Top 5, removes films and stops adding '
      'at five', (tester) async {
    final films = [
      for (var i = 1; i <= 5; i++) Film(imdbId: 'tt$i', title: 'Film $i'),
    ];
    final bloc = HomeBloc(
      repository: FakeHomeRepository(seed: {HomeList.top5: films}),
      gateway: FakePointsGateway(),
    )..add(const HomeStarted());
    addTearDown(bloc.close);
    await tester.pumpWidget(_app(
      bloc,
      EditFilmListScreen(list: HomeList.top5, title: _en.homeTop5Title),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Film 1'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text(_en.homeEditListFull), findsOneWidget);
    expect(find.byKey(const Key('edit-list-add')), findsNothing);

    await tester.tap(find.byKey(const Key('edit-list-remove-tt3')));
    await tester.pumpAndSettle();

    expect(find.text('Film 3'), findsNothing);
    expect(find.byKey(const Key('edit-list-add')), findsOneWidget);
  });

  testWidgets('the menu shares the list as text', (tester) async {
    final films = [
      for (var i = 1; i <= 2; i++) Film(imdbId: 'tt$i', title: 'Film $i'),
    ];
    final bloc = HomeBloc(
      repository: FakeHomeRepository(seed: {
        HomeList.watched: [...films]
      }),
      gateway: FakePointsGateway(),
    )..add(const HomeStarted());
    addTearDown(bloc.close);
    String? shared;
    await tester.pumpWidget(_app(
      bloc,
      EditFilmListScreen(
        list: HomeList.watched,
        title: _en.homeWatchedTitle,
        share: (text) async => shared = text,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('edit-list-menu')));
    await tester.pumpAndSettle();
    // Random is a Watchlist feature.
    expect(find.byKey(const Key('edit-list-random')), findsNothing);
    await tester.tap(find.text(_en.homeListShare));
    await tester.pumpAndSettle();

    expect(
      shared,
      '${_en.homeListShareText(_en.homeWatchedTitle)}\n1. Film 1\n2. Film 2',
    );
  });

  testWidgets(
      'Watchlist edit shows the grid, and Pick at random opens the '
      'cover wall on a named film', (tester) async {
    final films = [
      for (var i = 1; i <= 3; i++) Film(imdbId: 'tt$i', title: 'Film $i'),
    ];
    final bloc = HomeBloc(
      repository: FakeHomeRepository(seed: {
        HomeList.watchlist: [...films]
      }),
      gateway: FakePointsGateway(),
    )..add(const HomeStarted());
    addTearDown(bloc.close);
    await tester.pumpWidget(_app(
      bloc,
      EditFilmListScreen(
        list: HomeList.watchlist,
        title: _en.homeWatchlistTitle,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('edit-list-remove-tt1')), findsOneWidget);
    expect(find.byKey(const Key('lens-field')), findsNothing);

    await tester.tap(find.byKey(const Key('edit-list-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_en.homeListRandom));
    // The rings keep moving, so wait a set time instead of settling.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(RandomPickScreen), findsOneWidget);
    expect(find.byKey(const Key('lens-label')), findsOneWidget);
    expect(find.byKey(const Key('lens-picked')), findsOneWidget);
    final label = tester.widget<Text>(find.descendant(
      of: find.byKey(const Key('lens-label')),
      matching: find.byType(Text),
    ));
    expect(films.map((f) => f.title), contains(label.data));

    // Another roll keeps a film picked.
    await tester.tap(find.byKey(const Key('random-again')));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byKey(const Key('lens-picked')), findsOneWidget);
  });

  testWidgets('covers in Collections have no remove button', (tester) async {
    final bloc = HomeBloc(
      repository: FakeHomeRepository(),
      gateway: FakePointsGateway(),
    )..add(const HomeStarted());
    addTearDown(bloc.close);
    const dune = Film(imdbId: 'tt1', title: 'Dune');
    await tester.pumpWidget(_app(
      bloc,
      Scaffold(
        body: SingleChildScrollView(
          child: FilmsTab(
            movieLists: FakeMovieListRepository(),
            exitInset: _noInset,
            state: const HomeLoaded(sections: {
              HomeList.top5: SectionContent([dune]),
              HomeList.watched: SectionContent([dune]),
              HomeList.watchlist: SectionContent([dune]),
            }),
          ),
        ),
      ),
    ));

    expect(find.byTooltip(_en.homeRemoveFilm('Dune')), findsNothing);
  });
}

double _noInset(double _) => 0;

Widget _app(HomeBloc bloc, Widget child) => MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider.value(value: bloc, child: child),
    );

Future<void> _pumpTab(WidgetTester tester, HomeBloc bloc) =>
    tester.pumpWidget(_app(
      bloc,
      Scaffold(
        body: SingleChildScrollView(
          child: FilmsTab(
            movieLists: FakeMovieListRepository(),
            exitInset: (_) => 0,
            state: const HomeLoaded(sections: {
              HomeList.top5: SectionContent([]),
              HomeList.watched: SectionContent([]),
              HomeList.watchlist: SectionContent([]),
            }),
          ),
        ),
      ),
    ));
