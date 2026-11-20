import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/messaging/data/messaging_models.dart';
import 'package:film_wise_mobile/features/messaging/views/list_card.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _en = lookupAppLocalizations(const Locale('en'));

void main() {
  test('a list message carries the list it shares', () {
    final message = ChatMessage.fromJson({
      'id': 9,
      'kind': 'list',
      'body': 'Watch these',
      'sender': {'id': 1, 'username': 'me'},
      'created_at': '2026-11-20T03:00:00Z',
      'payload': {
        'event': 'shared',
        'list': {
          'id': 4,
          'name': 'The Tarantino Collection',
          'owner': 'Samlap09',
          'film_count': 10,
          'posters': ['https://img.test/1.jpg'],
        },
      },
    });

    expect(message.kind, MessageKind.list);
    expect(message.sharedList?.listId, 4);
    expect(message.sharedList?.name, 'The Tarantino Collection');
    expect(message.sharedList?.filmCount, 10);
  });

  testWidgets('a list card shows the name, who made it and how many films',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: ListCard(
          list: SharedList(
              listId: 4, name: 'Heist films', owner: 'ana', filmCount: 3),
        ),
      ),
    ));

    expect(find.text(_en.chatListShared), findsOneWidget);
    expect(find.text('Heist films'), findsOneWidget);
    expect(find.text('${_en.listBy('ana')} · ${_en.listFilmCount(3)}'),
        findsOneWidget);
  });
}
