import 'package:film_wise_mobile/features/film_reviews/presentation/take_hero.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Regression: the feed card is a tappable InkWell in a Scaffold. Tapping it pushes a
// route, and the Hero flight is painted in the Overlay, which has no Material ancestor.
// The shuttle must provide its own Material, or the InkWell throws
// "No Material widget found" during the transition.
void main() {
  testWidgets('hero flight of a tappable card does not need a Material ancestor',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: Scaffold(
          body: Center(
            child: Hero(
              tag: 'take',
              flightShuttleBuilder: takeHeroFlightShuttle,
              child: InkWell(
                onTap: () {},
                child: const SizedBox(
                  width: 200,
                  height: 120,
                  child: Text('take'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    navigatorKey.currentState!.push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(
          body: Center(child: Hero(tag: 'take', child: Text('detail'))),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.byType(ClipRect), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
