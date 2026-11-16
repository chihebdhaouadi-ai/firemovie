import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/film_reviews/data/translation_repository.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/widgets/translatable_text.dart';
import 'package:film_wise_mobile/features/find/data/movie.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _en = lookupAppLocalizations(const Locale('en'));

class FakeTranslationRepository implements TranslationRepository {
  FakeTranslationRepository({this.result, this.error});

  final TranslatedText? result;
  final Exception? error;
  final calls = <(String, String)>[];

  @override
  Future<TranslatedText> translate(
    String text, {
    required String targetLanguage,
  }) async {
    calls.add((text, targetLanguage));
    if (error != null) throw error!;
    return result!;
  }
}

Future<void> _pump(
  WidgetTester tester,
  TranslationRepository repository, {
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: TranslatableText(
          text: 'Très bon film',
          repository: repository,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('translates on tap and toggles back to the original',
      (tester) async {
    final repository = FakeTranslationRepository(
      result: const TranslatedText(text: 'Very good film', sourceLanguage: 'fr'),
    );
    await _pump(tester, repository);

    await tester.tap(find.text(_en.reviewTranslate));
    await tester.pumpAndSettle();

    expect(find.text('Very good film'), findsOneWidget);
    expect(find.text(_en.reviewShowOriginal), findsOneWidget);
    expect(repository.calls, [('Très bon film', 'en')]);

    await tester.tap(find.text(_en.reviewShowOriginal));
    await tester.pumpAndSettle();

    expect(find.text('Très bon film'), findsOneWidget);
    expect(find.text('Very good film'), findsNothing);
    expect(repository.calls, hasLength(1));
  });

  testWidgets('targets the app language', (tester) async {
    final fr = lookupAppLocalizations(const Locale('fr'));
    final repository = FakeTranslationRepository(
      result: const TranslatedText(text: 'Bonjour', sourceLanguage: 'en'),
    );
    await _pump(tester, repository, locale: const Locale('fr'));

    await tester.tap(find.text(fr.reviewTranslate));
    await tester.pumpAndSettle();

    expect(repository.calls.single.$2, 'fr');
  });

  testWidgets('shows a failure message and keeps the original text',
      (tester) async {
    final repository = FakeTranslationRepository(
      error: NetworkFailure('down'),
    );
    await _pump(tester, repository);

    await tester.tap(find.text(_en.reviewTranslate));
    await tester.pumpAndSettle();

    expect(find.text(_en.reviewTranslateFailed), findsOneWidget);
    expect(find.text('Très bon film'), findsOneWidget);
    expect(find.text(_en.reviewTranslate), findsOneWidget);
  });

  testWidgets('hides the link when the text is already in the app language',
      (tester) async {
    final repository = FakeTranslationRepository(
      result: const TranslatedText(text: 'Great film', sourceLanguage: 'en'),
    );
    await _pump(tester, repository);

    await tester.tap(find.text(_en.reviewTranslate));
    await tester.pumpAndSettle();

    expect(find.text(_en.reviewTranslate), findsNothing);
    expect(find.text('Très bon film'), findsOneWidget);
  });
}
