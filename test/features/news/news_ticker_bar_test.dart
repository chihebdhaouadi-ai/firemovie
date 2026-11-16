import 'package:film_wise_mobile/features/news/views/news_ticker_bar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('pauses on desktop hover and keeps ticker headlines tappable',
      (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    String? tappedItem;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 380,
              child: NewsTickerBar(
                items: const [
                  NewsTickerItem(
                    id: 'one',
                    headline: 'First headline',
                    posterUrl: '',
                  ),
                  NewsTickerItem(
                    id: 'two',
                    headline: 'Second headline',
                    posterUrl: '',
                  ),
                ],
                onItemTap: (id) => tappedItem = id,
                onSeeAllTap: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    final scrollable = tester.state<ScrollableState>(
      find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    final headline = find.text('First headline');
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(headline));
    await mouse.moveTo(tester.getCenter(headline));
    await tester.pump();
    final pausedOffset = scrollable.position.pixels;
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
    expect(scrollable.position.pixels, pausedOffset);

    await tester.tap(headline);
    expect(tappedItem, 'one');
  });
}
