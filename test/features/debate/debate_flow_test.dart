import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/debate/data/debate_repository.dart';
import 'package:film_wise_mobile/features/debate/domain/debate.dart';
import 'package:film_wise_mobile/features/debate/presentation/debate_quiz_page.dart';
import 'package:film_wise_mobile/features/debate/presentation/debate_waiting_page.dart';
import 'package:film_wise_mobile/features/find/data/movie.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_debate_repository.dart';

final _en = lookupAppLocalizations(const Locale('en'));

Future<void> _pump(WidgetTester tester, FakeDebateRepository repo) async {
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    RepositoryProvider<DebateRepository>.value(
      value: repo,
      child: MaterialApp(
        theme: AppTheme.dark(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const DebateWaitingPage(
          opponentId: 5,
          opponentName: 'maya',
          pollInterval: Duration(seconds: 1),
        ),
      ),
    ),
  );
  await _settle(tester);
}

Future<void> _startQuiz(WidgetTester tester, FakeDebateRepository repo) async {
  await _pump(tester, repo);
  await _settle(tester);
  await _settle(tester);
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets('a pending invite keeps waiting and never opens the quiz',
      (tester) async {
    final repo = FakeDebateRepository(statuses: [DebateStatus.pending]);
    await _pump(tester, repo);
    await tester.pump(const Duration(seconds: 3));

    expect(find.text(_en.debateWaitingTitle('maya')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(DebateQuizPage), findsNothing);
    expect(repo.statusRequests, greaterThan(0));
    expect(repo.questionRequests, 0);
  });

  testWidgets('an accepted invite opens the five question quiz',
      (tester) async {
    final repo = FakeDebateRepository();
    await _startQuiz(tester, repo);

    expect(find.byType(DebateQuizPage), findsOneWidget);
    expect(find.text(_en.debateQuestionCounter(1, 5)), findsOneWidget);
    expect(find.text(sampleQuestions.first.prompt), findsOneWidget);
    expect(repo.questionRequests, 1);
  });

  testWidgets('a declined invite says so and can be closed', (tester) async {
    final repo = FakeDebateRepository(statuses: [DebateStatus.declined]);
    await _pump(tester, repo);

    expect(find.text(_en.debateDeclined('maya')), findsOneWidget);
    expect(find.text(_en.debateDone), findsOneWidget);
    expect(find.byType(DebateQuizPage), findsNothing);
  });

  testWidgets('answering every question shows the winner and sage points',
      (tester) async {
    final repo = FakeDebateRepository(
      result: const DebateResult(
        myScore: 4,
        opponentScore: 2,
        outcome: DebateOutcome.won,
        sagePoints: 40,
      ),
    );
    await _startQuiz(tester, repo);

    for (final question in sampleQuestions) {
      await tester
          .tap(find.widgetWithText(FilledButton, question.choices.first));
      await tester.pump();
    }
    await _settle(tester);

    expect(
      repo.submissions.single,
      {for (final question in sampleQuestions) question.id: 0},
    );
    expect(find.text(_en.debateResultWon), findsOneWidget);
    expect(find.text(_en.debateScoreLine(4, 'maya', 2)), findsOneWidget);
    expect(find.text(_en.debateSagePointsWon(40)), findsOneWidget);
  });

  testWidgets('losing a debate shows the opponent and the points they receive',
      (tester) async {
    final repo = FakeDebateRepository(
      result: const DebateResult(
        myScore: 1,
        opponentScore: 4,
        outcome: DebateOutcome.lost,
        sagePoints: 25,
      ),
    );
    await _startQuiz(tester, repo);

    for (final question in sampleQuestions) {
      await tester.tap(find.widgetWithText(FilledButton, question.choices[1]));
      await tester.pump();
    }
    await _settle(tester);

    expect(find.text(_en.debateResultLost('maya')), findsOneWidget);
    expect(find.text(_en.debateSagePointsLost(25, 'maya')), findsOneWidget);
  });

  testWidgets('an unanswered question moves on when its countdown ends',
      (tester) async {
    final repo = FakeDebateRepository();
    await _startQuiz(tester, repo);

    await tester.pump(const Duration(seconds: 16));
    await _settle(tester);
    expect(find.text(_en.debateQuestionCounter(2, 5)), findsOneWidget);
    expect(find.text(sampleQuestions[1].prompt), findsOneWidget);

    for (var i = 1; i < sampleQuestions.length; i++) {
      await tester.pump(const Duration(seconds: 16));
    }
    await _settle(tester);

    expect(
      repo.submissions.single,
      {for (final question in sampleQuestions) question.id: null},
    );
  });

  testWidgets('a failed invite shows the invite error with retry',
      (tester) async {
    final repo = FakeDebateRepository(
      inviteError: ServerFailure('server', 'down'),
    );
    await _pump(tester, repo);

    expect(find.text(_en.debateInviteFailed), findsOneWidget);
    expect(find.text(_en.debateRetry), findsOneWidget);
    expect(find.byType(DebateQuizPage), findsNothing);
  });
}
