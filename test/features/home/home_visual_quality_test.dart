import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/home/data/home_models.dart';
import 'package:film_wise_mobile/features/home/views/widgets/film_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shared typography keeps supporting copy readable and subordinate', () {
    final textTheme = AppTheme.dark().textTheme;

    expect(textTheme.bodySmall?.fontSize, 13);
    expect(textTheme.bodyMedium?.fontSize, 15);
    expect(
      textTheme.bodySmall!.fontSize,
      lessThan(textTheme.titleSmall!.fontSize!),
    );
    expect(textTheme.bodySmall!.height, greaterThan(1.4));
  });

  testWidgets('home film posters keep a 2:3 aspect ratio', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: Center(
            child: FilmPoster(
              film: Film(imdbId: 'tt0000001', title: 'Dune'),
              width: 120,
            ),
          ),
        ),
      ),
    );

    final size = tester.getSize(find.byType(FilmPoster));
    expect(size.width, 120);
    expect(size.height, 180);
  });
}
