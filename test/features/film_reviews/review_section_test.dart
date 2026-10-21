import 'dart:convert';

import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/film_reaction.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/reaction_labels.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/review_section.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'review_test_support.dart';

final _en = lookupAppLocalizations(const Locale('en'));

Future<void> _pump(WidgetTester tester, ReviewApi api) async {
  await tester.binding.setSurfaceSize(const Size(800, 3000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            ReviewSection(
              movieId: 'tt1',
              repository: reviewRepositoryFor(api.client),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _reactionChip(FilmReaction reaction) =>
    find.widgetWithText(ChoiceChip, reactionChipLabel(_en, reaction));

void main() {
  testWidgets('loaded section shows the score, takes and the most helpful take',
      (tester) async {
    final api = ReviewApi(
      takes: [takeJson(id: 1, authorName: 'Ada', isMostHelpful: true)],
    );
    await _pump(tester, api);

    expect(find.text('84%'), findsOneWidget);
    expect(find.text(_en.reviewEveryoneTogether('71%')), findsOneWidget);
    expect(find.text(_en.reviewReactionTitle), findsOneWidget);
    expect(find.text(_en.reviewTakesTitle), findsOneWidget);
    expect(find.text(_en.reviewMostHelpful), findsOneWidget);
    expect(find.text('Ada'), findsOneWidget);
  });

  testWidgets('the most helpful label is not shown on the viewer own take',
      (tester) async {
    final api = ReviewApi(
      takes: [takeJson(id: 1, isMine: true, isMostHelpful: true)],
    );
    await _pump(tester, api);

    expect(find.text(_en.reviewMostHelpful), findsNothing);
  });

  testWidgets('a failed summary shows an error and retry reloads it',
      (tester) async {
    final api = ReviewApi()..failing.add('summary');
    await _pump(tester, api);

    expect(find.text(_en.reviewSummaryFailed), findsOneWidget);

    api.failing.remove('summary');
    await tester.tap(find.widgetWithText(FilledButton, _en.reviewRetry));
    await tester.pumpAndSettle();

    expect(find.text(_en.reviewSummaryFailed), findsNothing);
    expect(find.text('84%'), findsOneWidget);
  });

  testWidgets('picking a reaction sends it and asks for an optional line',
      (tester) async {
    final api = ReviewApi();
    await _pump(tester, api);

    expect(find.text(_en.reviewWhyPrompt), findsNothing);

    await tester.tap(_reactionChip(FilmReaction.loved));
    await tester.pumpAndSettle();

    final put = api.requests.firstWhere((r) => r.method == 'PUT');
    expect(put.url.path, '/api/takes/films/tt1/reaction/');
    expect(jsonDecode(put.body), {'reaction': 'loved'});
    expect(find.text(_en.reviewWhyPrompt), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, _en.reviewNoThanks));
    await tester.pumpAndSettle();

    expect(find.text(_en.reviewWhyPrompt), findsNothing);
    expect(find.text(_en.reviewCountedThanks), findsOneWidget);
  });

  testWidgets('a refused reaction shows the failure message', (tester) async {
    final api = ReviewApi()..failing.add('reaction');
    await _pump(tester, api);

    await tester.tap(_reactionChip(FilmReaction.loved));
    await tester.pumpAndSettle();

    expect(find.text(_en.reviewReactionFailed), findsOneWidget);
    expect(find.text(_en.reviewWhyPrompt), findsNothing);
  });

  testWidgets('an empty take only focuses the box, a written take posts',
      (tester) async {
    final api = ReviewApi();
    await _pump(tester, api);
    await tester.tap(_reactionChip(FilmReaction.loved));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, _en.reviewShare));
    await tester.pumpAndSettle();

    expect(api.requests.where((r) => r.method == 'POST'), isEmpty);
    expect(find.text(_en.reviewWhyPrompt), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Stays with me.');
    await tester.tap(find.widgetWithText(FilledButton, _en.reviewShare));
    await tester.pumpAndSettle();

    final post = api.requests.singleWhere((r) => r.method == 'POST');
    expect(post.url.path, '/api/takes/films/tt1/takes/');
    expect(jsonDecode(post.body), {'body': 'Stays with me.'});
    expect(find.text(_en.reviewSharedThanks), findsOneWidget);
    expect(find.text(_en.reviewWhyPrompt), findsNothing);
  });

  testWidgets('tapping a vote chip records the vote', (tester) async {
    final api = ReviewApi(takes: [takeJson(id: 7, wellArgued: 2)]);
    await _pump(tester, api);

    await tester.tap(
      find.widgetWithText(FilterChip, '${_en.reviewVoteWellArgued} 2'),
    );
    await tester.pumpAndSettle();

    final put = api.requests.singleWhere((r) => r.method == 'PUT');
    expect(put.url.path, '/api/takes/takes/7/votes/well_argued/');
    expect(jsonDecode(put.body), {'active': true});
  });

  testWidgets('the trust explanation expands on tap', (tester) async {
    await _pump(tester, ReviewApi());

    expect(find.text(_en.reviewTrustedNote), findsNothing);

    await tester.tap(find.text(_en.reviewWhatIsTrusted));
    await tester.pumpAndSettle();

    expect(find.text(_en.reviewTrustedNote), findsOneWidget);
  });
}
