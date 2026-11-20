import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/film_reaction.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take_tag.dart';
import 'package:film_wise_mobile/features/home/views/widgets/take_summary_card.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Take _take(int id, String body) => Take(
      id: id,
      authorId: 7,
      authorName: 'maya',
      isMine: false,
      reaction: FilmReaction.loved,
      body: body,
      votes: const {},
      myVotes: const {},
      commentCount: 0,
      isMostHelpful: false,
      tag: TakeTag.review,
    );

Future<void> _pump(WidgetTester tester, Take take, VoidCallback onTap) =>
    tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SizedBox(
          width: 320,
          child: TakeSummaryCard(take: take, onTap: onTap),
        ),
      ),
    ));

void main() {
  testWidgets('a take longer than four lines offers See more, which opens it',
      (tester) async {
    var opened = 0;
    await _pump(tester, _take(1, 'A long thought. ' * 40), () => opened++);
    await tester.pump();

    final seeMore = find.byKey(const Key('take-see-more-1'));
    expect(seeMore, findsOneWidget);
    await tester.tap(seeMore);
    expect(opened, 1);
  });

  testWidgets('a short take has no See more', (tester) async {
    await _pump(tester, _take(2, 'So good'), () {});
    await tester.pump();

    expect(find.byKey(const Key('take-see-more-2')), findsNothing);
  });
}
