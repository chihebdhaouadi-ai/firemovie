import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/find/data/find_repository.dart';
import 'package:film_wise_mobile/features/find/data/movie.dart';
import 'package:film_wise_mobile/features/find/views/film_detail_screen.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/reaction_labels.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/film_reaction.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../film_reviews/review_test_support.dart';

class _FakeFindRepository extends FindRepository {
  _FakeFindRepository(this.movie);

  final Movie movie;

  @override
  Future<Movie> fetchDetail(String filmId) async => movie;

  @override
  Future<List<String>> fetchStills(String filmId) async => const [];
}

const _movie = Movie(
  id: '278',
  title: 'Pulp Fiction',
  year: 1994,
  director: 'Quentin Tarantino',
  genres: ['Crime', 'Drama'],
  overview: 'A story about intersecting lives in Los Angeles.',
  runtime: 154,
  voteAverage: 8.5,
);

Future<void> _pumpDetail(WidgetTester tester, ReviewApi reviewApi) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: FilmDetailScreen(
        movie: _movie,
        repository: _FakeFindRepository(_movie),
        reviewRepository: reviewRepositoryFor(reviewApi.client),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders movie info with the live review section',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final reviewApi = ReviewApi(
      takes: [takeJson(authorName: 'Ada', body: 'A real test take')],
    );
    await _pumpDetail(tester, reviewApi);

    expect(find.text('Pulp Fiction'), findsOneWidget);
    expect(find.textContaining('Quentin Tarantino'), findsOneWidget);
    expect(find.text('DEMO'), findsNothing);
    expect(find.text('84%'), findsOneWidget);
    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.reviewReactionTitle), findsOneWidget);
    expect(find.text(l10n.reviewTakesTitle), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('film-detail-header'))).width,
      640,
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('film-detail-tabs'))).width,
      640,
    );
    final actionRow = find.byKey(const ValueKey('film-detail-actions'));
    expect(tester.getSize(actionRow).width, 600);
    final actionPills = find.descendant(
      of: actionRow,
      matching: find.byType(InkWell),
    );
    expect(actionPills, findsNWidgets(3));
    for (final pill in actionPills.evaluate()) {
      expect(
          tester.getSize(find.byWidget(pill.widget)).width, closeTo(194.7, 1));
    }

    await tester.ensureVisible(find.text(l10n.reviewReactionTapToReact));
    await tester.tap(find.text(l10n.reviewReactionTapToReact));
    await tester.pumpAndSettle();
    await tester.tap(find.text(reactionEmoji(FilmReaction.loved)));
    await tester.pumpAndSettle();
    expect(find.text(l10n.reviewReactionChange), findsOneWidget);
    expect(
      reviewApi.requests.any(
        (request) =>
            request.method == 'PUT' && request.url.path.endsWith('/reaction/'),
      ),
      isTrue,
    );
  });
}
