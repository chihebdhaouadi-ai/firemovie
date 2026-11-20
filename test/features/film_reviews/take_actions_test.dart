import 'dart:convert';

import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/film_reviews/data/take_actions_repository.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/report_reason.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take_skin.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/widgets/mention_suggestions.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/widgets/spoiler_shield.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/widgets/take_actions.dart';
import 'package:film_wise_mobile/features/find/data/api_client.dart';
import 'package:film_wise_mobile/features/home/data/home_models.dart';
import 'package:film_wise_mobile/features/social/data/social_models.dart';
import 'package:film_wise_mobile/features/social/data/social_repository.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _json = {'content-type': 'application/json'};

Take _take({bool mine = false}) => Take(
      id: 7,
      authorId: 2,
      authorName: 'ana',
      isMine: mine,
      reaction: null,
      body: 'A slow burn.',
      votes: const {},
      myVotes: const {},
      commentCount: 0,
      isMostHelpful: false,
    );

class _FakeActions implements TakeActionsRepository {
  final List<String> calls = [];
  ReportReason? reason;
  List<int>? recipients;
  String? message;
  bool? spoiler;

  @override
  Future<void> deleteTake(int takeId) async => calls.add('delete $takeId');

  @override
  Future<Take> editTake(int takeId,
      {required String body, TakeSkin? skin, bool? spoiler}) async {
    calls.add('edit $takeId $body ${skin?.apiValue}');
    this.spoiler = spoiler;
    return _take(mine: true);
  }

  @override
  Future<FeedItem> fetchTake(int takeId) => throw UnimplementedError();

  @override
  Future<void> reportTake(int takeId,
      {required ReportReason reason, String details = ''}) async {
    calls.add('report $takeId');
    this.reason = reason;
  }

  @override
  Future<int> shareTake(int takeId,
      {required List<int> recipientIds, String message = ''}) async {
    recipients = recipientIds;
    this.message = message;
    return recipientIds.length;
  }
}

class _FakeSocial implements SocialRepository {
  @override
  Future<Connections> connections() async =>
      const Connections(following: [], followers: [], friends: [
        SocialUser(id: 3, username: 'ben'),
        SocialUser(id: 4, username: 'cara'),
      ]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pumpMenu(
  WidgetTester tester, {
  required Take take,
  required _FakeActions actions,
  ValueChanged<Take>? onEdited,
  VoidCallback? onDeleted,
}) async {
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.dark(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Center(
        child: TakeMenuButton(
          take: take,
          actions: actions,
          social: _FakeSocial(),
          onEdited: onEdited ?? (_) {},
          onDeleted: onDeleted ?? () {},
        ),
      ),
    ),
  ));
  await tester.tap(find.byTooltip('More options'));
  await tester.pumpAndSettle();
}

void main() {
  group('mentions', () {
    TextEditingValue at(String text) => TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );

    test('reads the partial name before the cursor', () {
      expect(mentionQueryAt(at('hey @be')), 'be');
      expect(mentionQueryAt(at('@')), '');
      expect(mentionQueryAt(at('mail me@be')), isNull);
      expect(mentionQueryAt(at('@ben done')), isNull);
    });

    test('completes the name and moves the cursor after it', () {
      final value = insertMention(at('what do you think @be'), 'ben');
      expect(value.text, 'what do you think @ben ');
      expect(value.selection.baseOffset, value.text.length);
    });
  });

  test('share and mention notifications carry the take to open', () {
    final page = NotificationsPage.fromJson({
      'unread_count': 2,
      'results': [
        {
          'id': 1,
          'kind': 'take_shared',
          'actor': {'id': 2, 'username': 'ana'},
          'take': {'id': 7, 'film_id': 'tt1', 'tag': 'review', 'body': 'Wow'},
          'message': 'Read this',
        },
        {
          'id': 2,
          'kind': 'take_mention',
          'actor': {'id': 2, 'username': 'ana'},
          'take': {'id': 8, 'film_id': '', 'tag': 'question', 'body': 'Why?'},
          'comment_id': 30,
        },
        // A share whose take is gone is skipped.
        {
          'id': 3,
          'kind': 'take_shared',
          'actor': {'id': 2, 'username': 'ana'},
          'take': null,
        },
      ],
    });

    expect(page.items, hasLength(2));
    final shared = page.items.first;
    expect(shared.kind, NotificationKind.takeShared);
    expect(shared.take!.id, 7);
    expect(shared.take!.isReview, isTrue);
    expect(shared.message, 'Read this');
    final mention = page.items.last;
    expect(mention.kind, NotificationKind.takeMention);
    expect(mention.commentId, 30);
    expect(mention.take!.isReview, isFalse);
  });

  test('the actions repository calls the take endpoints', () async {
    final seen = <http.Request>[];
    final repository = ApiTakeActionsRepository(
      client: ApiClient(
        httpClient: MockClient((request) async {
          seen.add(request);
          if (request.method == 'DELETE') return http.Response('', 204);
          if (request.url.path.endsWith('/share/')) {
            return http.Response(jsonEncode({'sent': 2}), 201, headers: _json);
          }
          if (request.url.path.endsWith('/report/')) {
            return http.Response(jsonEncode({'reported': true}), 201,
                headers: _json);
          }
          return http.Response(
            jsonEncode({
              'id': 7,
              'author_id': 2,
              'author_name': 'ana',
              'is_mine': true,
              'body': 'Better.',
              'skin': 'electric_thunder',
              'edited': true,
              'film': {'film_id': 'tt1'},
            }),
            200,
            headers: _json,
          );
        }),
      ),
    );

    final edited = await repository.editTake(7,
        body: 'Better.', skin: TakeSkin.electricThunder);
    await repository.reportTake(7, reason: ReportReason.spoiler);
    final sent = await repository.shareTake(7, recipientIds: [3, 4]);
    await repository.deleteTake(7);
    final item = await repository.fetchTake(7);

    expect(edited.edited, isTrue);
    expect(edited.skin, TakeSkin.electricThunder);
    expect(sent, 2);
    expect(item.film.imdbId, 'tt1');
    expect(
      seen.map((r) => '${r.method} ${r.url.path}'),
      [
        'PATCH /api/takes/takes/7/',
        'POST /api/takes/takes/7/report/',
        'POST /api/takes/takes/7/share/',
        'DELETE /api/takes/takes/7/',
        'GET /api/takes/takes/7/',
      ],
    );
    expect(jsonDecode(seen[0].body),
        {'body': 'Better.', 'skin': 'electric_thunder'});
    expect(jsonDecode(seen[1].body), {'reason': 'spoiler'});
    expect(jsonDecode(seen[2].body), {
      'recipient_ids': [3, 4]
    });
  });

  testWidgets('the author sees edit and delete, not report', (tester) async {
    await _pumpMenu(tester, take: _take(mine: true), actions: _FakeActions());

    expect(find.text('Send to friends'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Report'), findsNothing);
  });

  testWidgets('others can report with a reason', (tester) async {
    final actions = _FakeActions();
    await _pumpMenu(tester, take: _take(), actions: actions);
    expect(find.text('Edit'), findsNothing);

    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unmarked spoiler'));
    await tester.pump();
    await tester.tap(find.text('Send report'));
    await tester.pumpAndSettle();

    expect(actions.calls, ['report 7']);
    expect(actions.reason, ReportReason.spoiler);
    expect(find.text('Thanks. Our team will review it.'), findsOneWidget);
  });

  testWidgets('sharing sends the take to the picked friends', (tester) async {
    final actions = _FakeActions();
    await _pumpMenu(tester, take: _take(), actions: actions);

    await tester.tap(find.text('Send to friends'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('cara'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Watch this');
    await tester.tap(find.text('Send to 1 friend'));
    await tester.pumpAndSettle();

    expect(actions.recipients, [4]);
    expect(actions.message, 'Watch this');
    expect(find.text('Sent to 1 friend'), findsOneWidget);
  });

  testWidgets('deleting asks first, then tells the page', (tester) async {
    final actions = _FakeActions();
    var deleted = false;
    await _pumpMenu(
      tester,
      take: _take(mine: true),
      actions: actions,
      onDeleted: () => deleted = true,
    );

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this take?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(actions.calls, ['delete 7']);
    expect(deleted, isTrue);
  });

  testWidgets('editing saves the new body', (tester) async {
    final actions = _FakeActions();
    Take? saved;
    await _pumpMenu(
      tester,
      take: _take(mine: true),
      actions: actions,
      onEdited: (take) => saved = take,
    );

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'A slower burn.');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(actions.calls, ['edit 7 A slower burn. normal']);
    expect(actions.spoiler, isFalse);
    expect(saved, isNotNull);
  });

  testWidgets('editing can mark the take as a spoiler', (tester) async {
    final actions = _FakeActions();
    await _pumpMenu(tester, take: _take(mine: true), actions: actions);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('spoiler-yes')));
    await tester.tap(find.byKey(const Key('spoiler-yes')));
    await tester.pumpAndSettle();
    // The preview now shows how readers will see it.
    expect(find.byKey(const Key('spoiler-reveal')), findsOneWidget);
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(actions.spoiler, isTrue);
  });

  testWidgets('a spoiler stays blurred until tapped', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: SpoilerShield(hidden: true, child: Text('Rosebud is a sled.')),
      ),
    ));

    expect(find.text('Contains spoilers'), findsOneWidget);
    expect(find.bySemanticsLabel('Contains spoilers. Tap to reveal'),
        findsOneWidget);
    await tester.tap(find.byKey(const Key('spoiler-reveal')));
    await tester.pump();

    expect(find.text('Contains spoilers'), findsNothing);
    expect(find.text('Rosebud is a sled.'), findsOneWidget);
    semantics.dispose();
  });
}
