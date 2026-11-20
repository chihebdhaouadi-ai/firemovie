import 'dart:convert';

import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/film_reaction.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/reaction_labels.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/review_section.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

import 'review_test_support.dart';

final _en = lookupAppLocalizations(const Locale('en'));
final _ar = lookupAppLocalizations(const Locale('ar'));

Future<void> _pump(
  WidgetTester tester,
  ReviewApi api, {
  bool settle = true,
  Locale? locale,
  bool accessible = false,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  await tester.binding.setSurfaceSize(const Size(800, 3000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          accessibleNavigation: accessible,
          textScaler: textScaler,
        ),
        child: child!,
      ),
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
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump();
  }
}

Finder _reactionButton(AppLocalizations l10n) =>
    find.widgetWithText(FilledButton, l10n.reviewReactionTapToReact);

Finder _pickerItem(FilmReaction reaction) =>
    find.text(reactionEmoji(reaction));

Future<void> _openPicker(WidgetTester tester, AppLocalizations l10n) async {
  await tester.tap(_reactionButton(l10n));
  await tester.pumpAndSettle();
}

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

  testWidgets('only a take with more than five comments shows the flame',
      (tester) async {
    final api = ReviewApi(
      takes: [
        takeJson(id: 1, authorName: 'Ada', commentCount: 6),
        takeJson(id: 2, authorName: 'Bo', commentCount: 5),
      ],
    );
    await _pump(tester, api, settle: false);

    expect(find.byType(Lottie), findsOneWidget);
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Bo'), findsOneWidget);
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

  testWidgets('opening the picker shows all ten reactions', (tester) async {
    await _pump(tester, ReviewApi());

    await _openPicker(tester, _en);

    for (final reaction in FilmReaction.values) {
      expect(_pickerItem(reaction), findsOneWidget);
    }
    expect(find.text(_en.reviewReactionPickOne), findsOneWidget);
  });

  testWidgets('choosing a reaction sends it and asks for an optional line',
      (tester) async {
    final api = ReviewApi();
    await _pump(tester, api);

    expect(find.text(_en.reviewWhyPrompt), findsNothing);

    await _openPicker(tester, _en);
    await tester.tap(_pickerItem(FilmReaction.loved));
    await tester.pumpAndSettle();

    final put = api.requests.firstWhere((r) => r.method == 'PUT');
    expect(put.url.path, '/api/takes/films/tt1/reaction/');
    expect(jsonDecode(put.body), {'reaction': 'loved'});
    expect(find.text(reactionLabel(_en, FilmReaction.loved)), findsOneWidget);
    expect(find.text(_en.reviewReactionChange), findsOneWidget);
    expect(find.text(_en.reviewWhyPrompt), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, _en.reviewNoThanks));
    await tester.pumpAndSettle();

    expect(find.text(_en.reviewWhyPrompt), findsNothing);
    expect(find.text(_en.reviewCountedThanks), findsOneWidget);
  });

  testWidgets('tapping outside the picker closes it without saving',
      (tester) async {
    final api = ReviewApi();
    await _pump(tester, api);

    await _openPicker(tester, _en);
    expect(_pickerItem(FilmReaction.loved), findsOneWidget);

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(_pickerItem(FilmReaction.loved), findsNothing);
    expect(api.requests.where((r) => r.method == 'PUT'), isEmpty);
    expect(find.text(_en.reviewWhyPrompt), findsNothing);
  });

  testWidgets('the accessible list fallback picks a reaction from a sheet',
      (tester) async {
    final api = ReviewApi();
    await _pump(tester, api, accessible: true);

    await tester.tap(_reactionButton(_en));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNWidgets(FilmReaction.values.length));
    expect(_pickerItem(FilmReaction.loved), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, _en.reviewReactionMadeCry));
    await tester.pumpAndSettle();

    final put = api.requests.singleWhere((r) => r.method == 'PUT');
    expect(jsonDecode(put.body), {'reaction': 'made_cry'});
    expect(find.byType(ListTile), findsNothing);
    expect(find.text(_en.reviewWhyPrompt), findsOneWidget);
  });

  testWidgets('the picker runs clockwise left-to-right and mirrors in RTL',
      (tester) async {
    await _pump(tester, ReviewApi());
    await _openPicker(tester, _en);
    final ltrFirst = tester.getCenter(_pickerItem(FilmReaction.values[0])).dx;
    final ltrSecond = tester.getCenter(_pickerItem(FilmReaction.values[1])).dx;
    expect(ltrSecond, greaterThan(ltrFirst));
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    await _pump(tester, ReviewApi(), locale: const Locale('ar'));
    await _openPicker(tester, _ar);
    final rtlFirst = tester.getCenter(_pickerItem(FilmReaction.values[0])).dx;
    final rtlSecond = tester.getCenter(_pickerItem(FilmReaction.values[1])).dx;
    expect(rtlSecond, lessThan(rtlFirst));
  });

  testWidgets('the picker and button survive a 2.0 text scale', (tester) async {
    final api = ReviewApi();
    await _pump(
      tester,
      api,
      textScaler: const TextScaler.linear(2.0),
    );

    await _openPicker(tester, _en);
    for (final reaction in FilmReaction.values) {
      expect(_pickerItem(reaction), findsOneWidget);
    }

    await tester.tap(_pickerItem(FilmReaction.masterpiece));
    await tester.pumpAndSettle();

    expect(find.text(_en.reviewReactionMasterpiece), findsOneWidget);
    expect(find.text(_en.reviewWhyPrompt), findsOneWidget);
  });

  testWidgets('a refused reaction shows the failure message', (tester) async {
    final api = ReviewApi()..failing.add('reaction');
    await _pump(tester, api);

    await _openPicker(tester, _en);
    await tester.tap(_pickerItem(FilmReaction.loved));
    await tester.pumpAndSettle();

    expect(find.text(_en.reviewReactionFailed), findsOneWidget);
    expect(find.text(_en.reviewWhyPrompt), findsNothing);
  });

  testWidgets('an empty take only focuses the box, a written take posts',
      (tester) async {
    final api = ReviewApi();
    await _pump(tester, api);
    await _openPicker(tester, _en);
    await tester.tap(_pickerItem(FilmReaction.loved));
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
    expect(jsonDecode(post.body), {'body': 'Stays with me.', 'tag': 'review'});
    expect(find.text(_en.reviewSharedThanks), findsOneWidget);
    expect(find.text(_en.reviewWhyPrompt), findsNothing);
  });

  testWidgets('tapping the heart records an up vote', (tester) async {
    final api = ReviewApi(takes: [takeJson(id: 7, wellArgued: 2)]);
    await _pump(tester, api);

    expect(find.byType(FilterChip), findsNothing);
    await tester.tap(find.byKey(const Key('take-heart-7')));
    await tester.pumpAndSettle();

    final put = api.requests.singleWhere((r) => r.method == 'PUT');
    expect(put.url.path, '/api/takes/takes/7/votes/up/');
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
