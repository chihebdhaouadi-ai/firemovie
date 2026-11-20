import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/review_detail_screen.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/widgets/take_film_cover.dart';
import 'package:film_wise_mobile/features/home/data/home_models.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'review_test_support.dart';

const _viewport = Size(800, 600);

Future<void> _pump(
  WidgetTester tester,
  ReviewApi api, {
  required int takeId,
  Object? heroTag,
  Film? film,
}) async {
  await tester.binding.setSurfaceSize(_viewport);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ReviewDetailScreen(
        movieId: 'tt1',
        takeId: takeId,
        heroTag: heroTag,
        repository: reviewRepositoryFor(api.client),
        film: film,
        filmYear: film == null ? null : 1994,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows only the requested take', (tester) async {
    final api = ReviewApi(takes: [
      for (var id = 1; id <= 3; id++)
        takeJson(id: id, authorName: 'user$id', body: 'Take number $id'),
    ]);
    await _pump(tester, api, takeId: 2);

    expect(find.text('“Take number 2”'), findsOneWidget);
    expect(find.text('“Take number 1”'), findsNothing);
    expect(find.text('“Take number 3”'), findsNothing);
  });

  testWidgets('the film cover names the film above the take', (tester) async {
    final api = ReviewApi(takes: [takeJson(id: 1, body: 'Great film')]);
    await _pump(
      tester,
      api,
      takeId: 1,
      film: const Film(imdbId: 'tt1', title: 'Pulp Fiction'),
    );

    expect(find.byType(TakeCoverBackdrop), findsOneWidget);
    expect(find.text('Pulp Fiction'), findsOneWidget);
    expect(find.text('1994'), findsOneWidget);
  });

  testWidgets('without a film the take stands alone', (tester) async {
    final api = ReviewApi(takes: [takeJson(id: 1, body: 'Great film')]);
    await _pump(tester, api, takeId: 1);

    expect(find.byType(TakeCoverBackdrop), findsNothing);
  });

  testWidgets('opens the comments of the take', (tester) async {
    final api = ReviewApi(takes: [
      takeJson(id: 1, body: 'Great film'),
    ])
      ..comments.add(commentJson(body: 'Agreed'));
    await _pump(tester, api, takeId: 1);

    expect(find.text('Agreed'), findsOneWidget);
  });

  testWidgets('wraps the take in a hero with the given tag', (tester) async {
    final api = ReviewApi(takes: [takeJson(id: 1, body: 'Great film')]);
    const tag = ('Popular takes', 1);
    await _pump(tester, api, takeId: 1, heroTag: tag);

    expect(
      find.byWidgetPredicate((w) => w is Hero && w.tag == tag),
      findsOneWidget,
    );
  });

  Map<String, dynamic> lastPostBody(ReviewApi api) => jsonDecode(
        api.requests.lastWhere((r) => r.method == 'POST').body,
      ) as Map<String, dynamic>;

  Future<void> send(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();
  }

  testWidgets('a heart is the only reaction, saved as an up vote',
      (tester) async {
    final api = ReviewApi(takes: [takeJson(id: 1, body: 'Great film')]);
    await _pump(tester, api, takeId: 1);

    expect(find.byKey(const Key('vote-draw')), findsNothing);
    expect(find.byKey(const Key('vote-down')), findsNothing);
    await tester.tap(find.byKey(const Key('take-heart-1')));
    await tester.pumpAndSettle();

    expect(
      api.requests.map((r) => r.url.path),
      contains('/api/takes/takes/1/votes/up/'),
    );
  });

  testWidgets('comments are sent without a stance picker', (tester) async {
    final api = ReviewApi(takes: [takeJson(id: 1, body: 'Great film')]);
    await _pump(tester, api, takeId: 1);

    expect(find.byKey(const ValueKey('review-stance-changed_my_mind')),
        findsNothing);
    await send(tester, 'You convinced me');

    expect(lastPostBody(api).containsKey('stance'), isFalse);
    expect(find.text('You convinced me'), findsOneWidget);
  });

  testWidgets('replying threads the comment under its parent', (tester) async {
    final api = ReviewApi(takes: [takeJson(id: 1, body: 'Great film')])
      ..comments.add(commentJson(id: 9, body: 'Agreed'));
    await _pump(tester, api, takeId: 1);

    await tester.ensureVisible(find.text('Reply').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reply').first);
    await tester.pumpAndSettle();
    await send(tester, 'Same here');

    expect(lastPostBody(api)['parent_id'], 9);
    expect(lastPostBody(api).containsKey('stance'), isFalse);
  });
}
