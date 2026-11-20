import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/film_reviews/data/review_repository.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take_tag.dart';
import 'package:film_wise_mobile/features/home/data/home_models.dart';
import 'package:film_wise_mobile/features/home/views/widgets/trending_topics_section.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Take _topic(int id, String body,
        {int comments = 0, TakeTag? tag, String title = ''}) =>
    Take(
      title: title,
      id: id,
      authorId: 7,
      authorName: 'maya',
      isMine: false,
      reaction: null,
      body: body,
      votes: const {},
      myVotes: const {},
      commentCount: comments,
      isMostHelpful: false,
      tag: tag ?? TakeTag.question,
    );

class _Reviews implements ReviewRepository {
  @override
  Future<List<FeedItem>> fetchTrendingTopics() async => [
        FeedItem(
          film: const Film(imdbId: 'tt0113277', title: 'Heat'),
          take: _topic(42, 'Is the ending a cop-out?', comments: 9),
        ),
        FeedItem(
          film: const Film(imdbId: 'tt0137523', title: 'Fight Club'),
          take: _topic(43, 'Lets discuss', tag: TakeTag.discussion),
        ),
        FeedItem(
          film: const Film(imdbId: 'tt0468569', title: 'The Dark Knight'),
          take: _topic(44, 'He proved his point. ' * 12,
              title: 'Did Joker win?', tag: TakeTag.discussion, comments: 3),
        ),
      ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.dark(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: TrendingTopicsSection(reviews: _Reviews())),
  ));
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('a topic card shows its type, question, film block and replies',
      (tester) async {
    await _pump(tester);
    expect(find.text('Question'), findsOneWidget);
    expect(find.text('Is the ending a cop-out?'), findsOneWidget);
    // The film shows in an "About this movie" block.
    expect(find.text('Heat'), findsOneWidget);
    expect(find.byKey(const ValueKey('topic-film-tt0113277')), findsOneWidget);
    expect(find.text('9 replies'), findsOneWidget);
    expect(find.byKey(const ValueKey('topic-reply-42')), findsOneWidget);
  });

  testWidgets('no replies yet asks for the first one, and there are no votes',
      (tester) async {
    await _pump(tester);
    expect(find.text('Be the first to reply'), findsOneWidget);
    expect(find.byIcon(BootstrapIcons.hand_thumbs_up), findsNothing);
    expect(find.byIcon(BootstrapIcons.hand_thumbs_down), findsNothing);
  });

  testWidgets('a topic with a title shows it above the body', (tester) async {
    await _pump(tester);
    expect(find.text('Did Joker win?'), findsOneWidget);
    expect(find.textContaining('He proved his point.'), findsOneWidget);
  });

  testWidgets('a long topic offers "See more", a short one does not',
      (tester) async {
    await _pump(tester);
    expect(find.byKey(const ValueKey('topic-see-more-44')), findsOneWidget);
    expect(find.byKey(const ValueKey('topic-see-more-42')), findsNothing);
  });
}
