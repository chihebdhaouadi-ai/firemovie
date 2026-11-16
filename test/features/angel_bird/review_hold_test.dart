import 'package:film_wise_mobile/core/session.dart';
import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/angel_bird/angel_bird_host.dart';
import 'package:film_wise_mobile/features/debate/data/debate_repository.dart';
import 'package:film_wise_mobile/features/debate/domain/debate.dart';
import 'package:film_wise_mobile/features/debate/presentation/debate_waiting_page.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/film_reaction.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/state/movie_reviews_cubit.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/widgets/take_card.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../debate/fake_debate_repository.dart';
import '../film_reviews/review_test_support.dart';

final _en = lookupAppLocalizations(const Locale('en'));
final _navigatorKey = GlobalKey<NavigatorState>();

Take _take({bool isMine = false}) => Take(
      id: 1,
      authorId: 101,
      authorName: 'leo',
      isMine: isMine,
      reaction: FilmReaction.loved,
      body: 'Great film',
      votes: const {},
      myVotes: const {},
      commentCount: 2,
      isMostHelpful: false,
    );

Future<void> _pumpCard(
  WidgetTester tester,
  ReviewApi api, {
  bool isMine = false,
  FakeDebateRepository? debates,
}) async {
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final cubit = MovieReviewsCubit(
    filmId: 'tt1',
    repository: reviewRepositoryFor(api.client),
  );
  await tester.pumpWidget(
    RepositoryProvider<DebateRepository>.value(
      value: debates ?? FakeDebateRepository(),
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        theme: AppTheme.dark(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => AngelBirdHost(
          navigatorKey: _navigatorKey,
          child: child!,
        ),
        home: BlocProvider.value(
          value: cubit,
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child:
                  TakeCard(take: _take(isMine: isMine), isMostHelpful: false),
            ),
          ),
        ),
      ),
    ),
  );
  await _settle(tester);
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _hold(WidgetTester tester, Offset at, Duration duration) async {
  final gesture = await tester.startGesture(at);
  await tester.pump(duration);
  await gesture.up();
  await _settle(tester);
}

void main() {
  setUp(() => Session.token = 'token');
  tearDown(Session.clear);

  testWidgets('holding the review card for 1.7 s asks about a debate',
      (tester) async {
    final api = ReviewApi();
    await _pumpCard(tester, api);

    await _hold(
      tester,
      tester.getCenter(find.textContaining('Great film')),
      const Duration(milliseconds: 1800),
    );

    expect(find.text(_en.angelBirdReviewQuestion), findsOneWidget);
    expect(find.text(_en.angelBirdYes), findsOneWidget);
  });

  testWidgets('a short press on the review card does not summon the bird',
      (tester) async {
    final api = ReviewApi();
    await _pumpCard(tester, api);

    await _hold(
      tester,
      tester.getCenter(find.textContaining('Great film')),
      const Duration(milliseconds: 500),
    );

    expect(find.text(_en.angelBirdReviewQuestion), findsNothing);
  });

  testWidgets('holding a button inside the card does not summon the bird',
      (tester) async {
    final api = ReviewApi();
    await _pumpCard(tester, api);

    await _hold(
      tester,
      tester.getCenter(
        find.widgetWithText(TextButton, _en.reviewCommentsButton(2)),
      ),
      const Duration(milliseconds: 1800),
    );

    expect(find.text(_en.angelBirdReviewQuestion), findsNothing);
  });

  testWidgets('lists the writer and each commenter once', (tester) async {
    final api = ReviewApi()
      ..comments.addAll([
        commentJson(id: 7, authorId: 101, authorName: 'leo', isWriter: true),
        commentJson(id: 8, authorId: 5, authorName: 'maya'),
        commentJson(id: 9, authorId: 5, authorName: 'maya', body: 'Again'),
      ]);
    await _pumpCard(tester, api);
    await _hold(
      tester,
      tester.getCenter(find.textContaining('Great film')),
      const Duration(milliseconds: 1800),
    );

    await tester.tap(find.text(_en.angelBirdYes));
    await _settle(tester);

    expect(find.text(_en.angelBirdPickPerson), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'leo'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'maya'), findsOneWidget);
  });

  testWidgets('picking a participant asks them for a debate', (tester) async {
    final api = ReviewApi()
      ..comments.add(commentJson(id: 8, authorId: 5, authorName: 'maya'));
    final debates = FakeDebateRepository(statuses: [DebateStatus.pending]);
    await _pumpCard(tester, api, debates: debates);
    await _hold(
      tester,
      tester.getCenter(find.textContaining('Great film')),
      const Duration(milliseconds: 1800),
    );

    await tester.tap(find.text(_en.angelBirdYes));
    await _settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'maya'));
    await _settle(tester);

    expect(find.byType(DebateWaitingPage), findsOneWidget);
    expect(debates.invitedUserIds, [5]);
  });

  testWidgets('shows the empty message when nobody else is in the review',
      (tester) async {
    final api = ReviewApi();
    await _pumpCard(tester, api, isMine: true);
    await _hold(
      tester,
      tester.getCenter(find.textContaining('Great film')),
      const Duration(milliseconds: 1800),
    );

    await tester.tap(find.text(_en.angelBirdYes));
    await _settle(tester);

    expect(find.text(_en.angelBirdNoPeople), findsOneWidget);
  });

  testWidgets('logged out users never get the review question', (tester) async {
    Session.clear();
    final api = ReviewApi();
    await _pumpCard(tester, api);

    await _hold(
      tester,
      tester.getCenter(find.textContaining('Great film')),
      const Duration(milliseconds: 1800),
    );

    expect(find.text(_en.angelBirdReviewQuestion), findsNothing);
  });
}
