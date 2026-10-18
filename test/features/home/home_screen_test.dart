import 'dart:async';

import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/find/views/find_film_screen.dart';
import 'package:film_wise_mobile/features/home/bloc/home_bloc.dart';
import 'package:film_wise_mobile/features/home/bloc/home_screen_event.dart';
import 'package:film_wise_mobile/features/home/data/home_models.dart';
import 'package:film_wise_mobile/features/home/data/home_repository.dart';
import 'package:film_wise_mobile/features/home/views/home_screen.dart';
import 'package:film_wise_mobile/features/home/views/widgets/add_tile.dart';
import 'package:film_wise_mobile/features/home/views/widgets/skeletons.dart';
import 'package:film_wise_mobile/features/home/views/widgets/top5_row.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

const _dune = Film(imdbId: 'tt0000001', title: 'Dune');
const _arrival = Film(imdbId: 'tt0000002', title: 'Arrival');
const _interstellar = Film(imdbId: 'tt0000003', title: 'Interstellar');
const _blade = Film(imdbId: 'tt0000004', title: 'Blade Runner');
const _matrix = Film(imdbId: 'tt0000005', title: 'The Matrix');
const _inception = Film(imdbId: 'tt0000006', title: 'Inception');
const _popular = Film(imdbId: 'tt0000007', title: 'Popular Pick');

const _tallViewport = Size(360, 3000);
const _phoneViewport = Size(360, 800);

final _en = lookupAppLocalizations(const Locale('en'));

Map<HomeList, List<Film>> _contentSeed() => {
      HomeList.top5: [_dune, _arrival],
      HomeList.watched: [_interstellar, _blade, _matrix],
      HomeList.watchlist: [_inception],
      HomeList.popular: [_popular],
    };

class _HeldRepository extends FakeHomeRepository {
  final _gate = Completer<void>();

  void release() => _gate.complete();

  @override
  Future<List<Film>> fetch(HomeList list) async {
    await _gate.future;
    return super.fetch(list);
  }
}

class _FlakyRepository extends FakeHomeRepository {
  _FlakyRepository({
    super.seed,
    required this.failingLists,
    this.failures = 1,
  });

  final Set<HomeList> failingLists;
  int failures;

  @override
  Future<List<Film>> fetch(HomeList list) async {
    if (failingLists.contains(list) && failures > 0) {
      failures--;
      throw const HomeDataException('offline');
    }
    return super.fetch(list);
  }
}

class _FindStub extends StatelessWidget {
  const _FindStub({required this.onConfirm});

  final Future<void> Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () async {
            await onConfirm();
            if (context.mounted) Navigator.of(context).pop();
          },
          child: const Text('CONFIRM_FIND'),
        ),
      ),
    );
  }
}

Future<HomeBloc> pumpHome(
  WidgetTester tester, {
  required HomeRepository repository,
  double textScale = 1,
  Size viewport = _tallViewport,
}) async {
  tester.view.physicalSize = viewport;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final bloc = HomeBloc(
    repository: repository,
    gateway: FakeRecommendationGateway(),
  )..add(const HomeStarted());
  addTearDown(bloc.close);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {
        '/find': (context) => _FindStub(
              onConfirm: () => repository.add(HomeList.top5, _arrival),
            ),
      },
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
      home: BlocProvider.value(
        value: bloc,
        child: const HomeScreen(),
      ),
    ),
  );
  return bloc;
}

Finder _inTop5(Finder matching) =>
    find.descendant(of: find.byType(Top5Row), matching: matching);

Finder _filmLabel(Film film, String section) => find
    .bySemanticsLabel(_en.homeFilmTileSemantics(film.displayTitle, section));

Finder _generateButton() =>
    find.widgetWithText(FilledButton, _en.homeGenerateButton);

VoidCallback? _generatePressed(WidgetTester tester) =>
    tester.widget<FilledButton>(_generateButton()).onPressed;

void main() {
  setUpAll(() async {
    final poppins = FontLoader('Poppins')
      ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-Medium.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-SemiBold.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-Bold.ttf'));
    await poppins.load();
  });

  group('states', () {
    testWidgets('loading shows poster-shaped skeletons', (tester) async {
      final repository = _HeldRepository();
      await pumpHome(tester, repository: repository);
      await tester.pump();

      expect(find.byType(PosterSkeletonRow), findsNWidgets(3));
      expect(find.byType(PosterSkeleton), findsWidgets);

      repository.release();
      await tester.pumpAndSettle();
      expect(find.byType(PosterSkeleton), findsNothing);
    });

    testWidgets('empty lists show the empty state with an action',
        (tester) async {
      await pumpHome(tester, repository: FakeHomeRepository());
      await tester.pumpAndSettle();

      expect(find.text(_en.homeSectionEmptyTitle), findsNWidgets(3));
      expect(find.text(_en.homeSectionEmptyAction), findsNWidgets(2));
      expect(_inTop5(find.byType(AddTile)), findsNWidgets(5));
    });

    testWidgets('failed lists show an error with retry', (tester) async {
      await pumpHome(
        tester,
        repository: _FlakyRepository(
          failingLists: HomeList.values.toSet(),
          failures: 99,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(_en.homeSectionErrorTitle), findsNWidgets(4));
      expect(find.text(_en.homeSectionErrorRetry), findsNWidgets(4));
    });

    testWidgets('retry reloads only the failed list', (tester) async {
      await pumpHome(
        tester,
        repository: _FlakyRepository(
          seed: {
            HomeList.top5: [_dune],
          },
          failingLists: {HomeList.top5},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(_en.homeSectionErrorTitle), findsOneWidget);

      await tester.tap(_inTop5(find.text(_en.homeSectionErrorRetry)));
      await tester.pumpAndSettle();

      expect(_filmLabel(_dune, _en.homeTop5Title), findsOneWidget);
      expect(find.text(_en.homeSectionErrorTitle), findsNothing);
      expect(find.text(_en.homeSectionEmptyTitle), findsNWidgets(3));
    });

    testWidgets('content shows films and their counts', (tester) async {
      await pumpHome(
        tester,
        repository: FakeHomeRepository(seed: _contentSeed()),
      );
      await tester.pumpAndSettle();

      expect(_filmLabel(_dune, _en.homeTop5Title), findsOneWidget);
      expect(_filmLabel(_blade, _en.homeWatchedTitle), findsOneWidget);
      expect(_filmLabel(_inception, _en.homeWatchlistTitle), findsOneWidget);
      expect(_filmLabel(_popular, _en.homePopularTitle), findsOneWidget);
      expect(find.text(_en.homeFilmCount(3)), findsOneWidget);
      expect(find.text(_en.homeFilmCount(1)), findsNWidgets(2));
    });
  });

  group('top 5', () {
    testWidgets('tap on a Top 5 slot opens the Find screen for that destination',
        (tester) async {
      await pumpHome(
        tester,
        repository: FakeHomeRepository(
          seed: {
            HomeList.top5: [_dune],
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(_inTop5(find.byType(AddTile)).first);
      await tester.pumpAndSettle();

      // The Find screen is pushed with the Top 5 destination shown in its title.
      expect(find.byType(FindFilmScreen), findsOneWidget);
      expect(find.text(_en.findTitleTop5), findsWidgets);
    });

    testWidgets('removes a film optimistically and restores it with Undo',
        (tester) async {
      await pumpHome(
        tester,
        repository: FakeHomeRepository(
          seed: {
            HomeList.top5: [_dune, _arrival],
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip(_en.homeRemoveFilm('Dune')));
      await tester.pumpAndSettle();

      expect(_filmLabel(_dune, _en.homeTop5Title), findsNothing);
      expect(find.text(_en.homeRemovedSnackbar('Dune')), findsOneWidget);

      await tester.tap(find.text(_en.homeUndo));
      await tester.pumpAndSettle();

      expect(_filmLabel(_dune, _en.homeTop5Title), findsOneWidget);
    });
  });

  group('generate', () {
    testWidgets('GENERATE stays disabled until three films are picked',
        (tester) async {
      await pumpHome(
        tester,
        repository: FakeHomeRepository(seed: _contentSeed()),
      );
      await tester.pumpAndSettle();

      expect(_generatePressed(tester), isNull);
      expect(find.text(_en.homeGenerateDisabledHint(3)), findsOneWidget);

      await tester.tap(_filmLabel(_interstellar, _en.homeWatchedTitle));
      await tester.pumpAndSettle();
      await tester.tap(_filmLabel(_blade, _en.homeWatchedTitle));
      await tester.pumpAndSettle();

      expect(_generatePressed(tester), isNull);
      expect(find.text(_en.homeGenerateDisabledHint(1)), findsOneWidget);

      await tester.tap(_filmLabel(_matrix, _en.homeWatchedTitle));
      await tester.pumpAndSettle();

      expect(_generatePressed(tester), isNotNull);
      expect(find.text(_en.homeGenerateDisabledHint(1)), findsNothing);

      await tester.tap(_generateButton());
      await tester.pumpAndSettle();

      expect(find.text(_en.homeGenerateSuccess), findsOneWidget);
      expect(find.text(_en.homePointsLabel(100)), findsOneWidget);
    });
  });

  group('layout', () {
    testWidgets('text scale 2.0 renders without overflow', (tester) async {
      await pumpHome(
        tester,
        repository: FakeHomeRepository(seed: _contentSeed()),
        textScale: 2,
        viewport: _phoneViewport,
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('home matches golden at 360x800', (tester) async {
      await pumpHome(
        tester,
        repository: FakeHomeRepository(seed: _contentSeed()),
        viewport: _phoneViewport,
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(HomeScreen),
        matchesGoldenFile('goldens/home_360x800.png'),
      );
    });
  });
}
