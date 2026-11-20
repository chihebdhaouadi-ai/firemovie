import 'package:film_wise_mobile/features/film_reviews/domain/film_reaction.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/widgets/feeling_motion.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  bool reduceMotion = false,
}) {
  return tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, app) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
        child: app!,
      ),
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  testWidgets('a picked feeling icon loops its motion', (tester) async {
    await _pump(
      tester,
      const FeelingIcon(feeling: FilmReaction.loved, animate: true),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('icons and the empty smile stay still with reduced motion',
      (tester) async {
    await _pump(
      tester,
      const Column(
        children: [
          FeelingIcon(feeling: FilmReaction.madeCry, animate: true),
          FeelingsEmptyInvite(label: 'Tap'),
        ],
      ),
      reduceMotion: true,
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('at the limit, unpicked tiles ignore taps', (tester) async {
    final taps = <FilmReaction>[];
    await _pump(
      tester,
      SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: FeelingTileGrid(
            picked: const [
              FilmReaction.loved,
              FilmReaction.madeCry,
              FilmReaction.masterpiece,
            ],
            onToggle: taps.add,
          ),
        ),
      ),
      reduceMotion: true,
    );
    final en = lookupAppLocalizations(const Locale('en'));

    await tester.tap(find.text(en.reviewReactionBored));
    await tester.tap(find.text(en.reviewReactionLoved));

    expect(taps, [FilmReaction.loved]);
  });

  test('the hand-made Lottie animations parse', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    for (final path in [
      'assets/lottie/feel_smile.json',
      'assets/lottie/typing.json',
    ]) {
      final data = await rootBundle.load(path);
      final composition =
          await LottieComposition.fromBytes(data.buffer.asUint8List());
      expect(composition.duration, greaterThan(Duration.zero), reason: path);
    }
  });
}
