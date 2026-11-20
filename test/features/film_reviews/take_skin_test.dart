import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take_skin.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/widgets/take_skin_background.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

Widget _app(Widget child, {bool reduceMotion = false}) => MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Scaffold(body: child),
      ),
    );

void main() {
  test('server values map to skins and unknown ones fall back to normal', () {
    expect(TakeSkin.fromApi('electric_thunder'), TakeSkin.electricThunder);
    expect(TakeSkin.fromApi('normal'), TakeSkin.normal);
    expect(TakeSkin.fromApi(null), TakeSkin.normal);
    expect(TakeSkin.fromApi('rainbow'), TakeSkin.normal);
  });

  testWidgets('the normal skin leaves the card untouched', (tester) async {
    await tester.pumpWidget(_app(
      const TakeSkinBackground(skin: TakeSkin.normal, child: Text('Plain')),
    ));

    expect(find.text('Plain'), findsOneWidget);
    expect(find.byType(LottieBuilder), findsNothing);
  });

  testWidgets('electric thunder plays the lightning animation',
      (tester) async {
    await tester.pumpWidget(_app(
      const TakeSkinBackground(
        skin: TakeSkin.electricThunder,
        child: Text('Zap'),
      ),
    ));

    final lottie = tester.widget<LottieBuilder>(find.byType(LottieBuilder));
    expect(lottie.controller, isNull);
    expect(find.text('Zap'), findsOneWidget);
  });

  testWidgets('reduced motion shows a still lightning frame', (tester) async {
    await tester.pumpWidget(_app(
      const TakeSkinBackground(
        skin: TakeSkin.electricThunder,
        child: Text('Zap'),
      ),
      reduceMotion: true,
    ));

    final lottie = tester.widget<LottieBuilder>(find.byType(LottieBuilder));
    expect(lottie.controller, isA<AlwaysStoppedAnimation<double>>());
  });

  testWidgets('picking a skin updates the live preview', (tester) async {
    var skin = TakeSkin.normal;
    await tester.pumpWidget(_app(
      StatefulBuilder(
        builder: (context, setState) => Column(
          children: [
            TakeSkinPicker(
              selected: skin,
              onChanged: (value) => setState(() => skin = value),
            ),
            TakeSkinPreview(skin: skin, text: 'Loud and bright'),
          ],
        ),
      ),
    ));

    expect(find.text('Normal'), findsOneWidget);
    expect(find.text('“Loud and bright”'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Normal')),
      matchesSemantics(
        label: 'Normal',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );

    await tester.tap(find.text('Electric thunder'));
    await tester.pump();

    expect(skin, TakeSkin.electricThunder);
    // Still swatch in the picker plus the moving preview.
    final players = tester
        .widgetList<LottieBuilder>(find.byType(LottieBuilder))
        .map((lottie) => lottie.controller == null)
        .toList();
    expect(players, unorderedEquals([false, true]));
  });

  testWidgets('an empty take shows a placeholder in the preview',
      (tester) async {
    await tester.pumpWidget(_app(
      const TakeSkinPreview(skin: TakeSkin.normal, text: '  '),
    ));

    expect(find.text('Your take will appear here.'), findsOneWidget);
  });
}
