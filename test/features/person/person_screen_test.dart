import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/person/data/person_repository.dart';
import 'package:film_wise_mobile/features/person/domain/person.dart';
import 'package:film_wise_mobile/features/person/views/person_screen.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:film_wise_mobile/l10n/app_localizations_en.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _en = AppLocalizationsEn();

Widget _app(PersonRepository repository) => MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: PersonScreen(
        personId: '7455989',
        name: 'Joaquin Phoenix',
        subtitle: 'Arthur Fleck',
        repository: repository,
      ),
    );

void main() {
  testWidgets('shows height, biography and the films they were cast in',
      (tester) async {
    await tester.pumpWidget(_app(FakePersonRepository(
      person: PersonDetail(
        id: 'nm0001618',
        name: 'Joaquin Phoenix',
        heightDisplay: '5′ 8″ (1.73 m)',
        biography: 'An American actor.',
        birthDate: DateTime(1974, 10, 28),
        knownFor: const [
          PersonCredit(
            filmId: 'tt7286456',
            title: 'Joker',
            year: 2019,
            characters: ['Arthur Fleck'],
          ),
        ],
      ),
    )));
    await tester.pumpAndSettle();

    expect(find.text('Joaquin Phoenix'), findsOneWidget);
    expect(find.text(_en.personBiography), findsOneWidget);
    expect(find.text('An American actor.'), findsOneWidget);
    expect(find.textContaining('5′ 8″'), findsOneWidget);
    expect(find.text(_en.personFilmography), findsOneWidget);
    expect(find.text('Joker'), findsOneWidget);
    expect(find.text(_en.personAsCharacter('Arthur Fleck')), findsOneWidget);
  });

  testWidgets('a failed load offers a retry that reloads', (tester) async {
    final repository = FakePersonRepository(error: Exception('offline'));
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    expect(find.text(_en.personLoadFailed), findsOneWidget);
    await tester.tap(find.text(_en.reviewRetry));
    await tester.pumpAndSettle();
    expect(repository.calls, 2);
  });
}
