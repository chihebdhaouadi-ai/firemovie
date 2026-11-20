import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/film_reviews/data/review_repository.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/film_reaction.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take_tag.dart';
import 'package:film_wise_mobile/features/home/data/home_models.dart';
import 'package:film_wise_mobile/features/profile/views/widgets/saved_takes_section.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

FeedItem _item(int id) => FeedItem(
      film: Film(imdbId: 'tt000000$id', title: 'Film $id'),
      take: Take(
        id: id,
        authorId: 7,
        authorName: 'ana',
        isMine: false,
        reaction: FilmReaction.blewMind,
        body: 'Saved topic $id',
        tag: TakeTag.question,
        votes: const {},
        myVotes: const {},
        commentCount: 0,
        isMostHelpful: false,
        isSaved: true,
      ),
    );

class _SavedReviews implements ReviewRepository {
  _SavedReviews(this.items);

  final List<FeedItem> items;

  @override
  Future<List<FeedItem>> fetchSavedTakes() async => items;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(WidgetTester tester, List<FeedItem> items) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: SavedTakesSection(reviews: _SavedReviews(items)),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('says where saved topics will show when there are none',
      (tester) async {
    await _pump(tester, const []);

    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Topics you save show up here.'), findsOneWidget);
  });

  testWidgets('shows the first saved topics and a See all for the rest',
      (tester) async {
    await _pump(tester, [for (var id = 1; id <= 5; id++) _item(id)]);

    expect(find.byKey(const ValueKey('saved-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('saved-3')), findsOneWidget);
    expect(find.byKey(const ValueKey('saved-4')), findsNothing);
    expect(find.byKey(const Key('profile-saved-all')), findsOneWidget);
  });
}
