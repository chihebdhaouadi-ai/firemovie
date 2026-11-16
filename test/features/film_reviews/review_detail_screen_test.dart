import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/review_detail_screen.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'review_test_support.dart';

const _viewport = Size(800, 600);

Future<void> _pump(
  WidgetTester tester,
  ReviewApi api, {
  required int takeId,
  Object? heroTag,
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
}
