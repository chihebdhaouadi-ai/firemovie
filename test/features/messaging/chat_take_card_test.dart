import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/messaging/data/messaging_models.dart';
import 'package:film_wise_mobile/features/messaging/views/chat_message_tile.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _json(
        {String event = 'shared', bool withComment = false}) =>
    {
      'id': 5,
      'kind': 'take',
      'body': '',
      'sender': {'id': 2, 'username': 'ana'},
      'created_at': '2026-11-19T10:00:00Z',
      'payload': {
        'event': event,
        'take': {
          'id': 41,
          'tag': 'question',
          'title': 'Are we free?',
          'body': 'We work jobs we do not love.',
          'author': 'sam',
          'film_title': 'Fight Club',
          'poster': null,
        },
        if (withComment)
          'comment': {
            'id': 77,
            'parent_id': 70,
            'body': 'What do you think @ben?'
          },
      },
    };

Widget _app(Widget child) => MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  test('a take message carries the topic and, for a mention, the comment', () {
    final shared = ChatMessage.fromJson(_json());
    expect(shared.kind, MessageKind.take);
    expect(shared.sharedTake!.takeId, 41);
    expect(shared.sharedTake!.mention, isFalse);
    expect(shared.sharedTake!.commentId, isNull);

    final mention =
        ChatMessage.fromJson(_json(event: 'mention', withComment: true));
    expect(mention.sharedTake!.mention, isTrue);
    expect(mention.sharedTake!.commentId, 77);
    expect(mention.sharedTake!.commentBody, 'What do you think @ben?');
  });

  testWidgets('a shared topic shows as a card with its question and movie',
      (tester) async {
    final take = ChatMessage.fromJson(_json()).sharedTake!;
    await tester.pumpWidget(_app(TakeCard(take: take)));

    expect(find.text('Shared a topic'), findsOneWidget);
    expect(find.text('Are we free?'), findsOneWidget);
    expect(find.text('We work jobs we do not love.'), findsOneWidget);
    expect(find.text('Fight Club'), findsOneWidget);
  });

  testWidgets('a mention card quotes the comment that tagged you',
      (tester) async {
    final take =
        ChatMessage.fromJson(_json(event: 'mention', withComment: true))
            .sharedTake!;
    await tester.pumpWidget(_app(TakeCard(take: take)));

    expect(find.text('Tagged you in a comment'), findsOneWidget);
    expect(find.text('What do you think @ben?'), findsOneWidget);
  });

  testWidgets('the inbox preview says what the card is', (tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(_app(Builder(builder: (context) {
      l10n = AppLocalizations.of(context)!;
      return const SizedBox();
    })));
    final mention =
        ChatMessage.fromJson(_json(event: 'mention', withComment: true));
    expect(messageSnippet(l10n, mention), 'Tagged you in a comment');
    expect(messageSnippet(l10n, ChatMessage.fromJson(_json())), 'Are we free?');
  });
}
