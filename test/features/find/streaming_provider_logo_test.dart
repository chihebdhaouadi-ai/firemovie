import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/find/data/movie.dart';
import 'package:film_wise_mobile/features/find/views/widgets/streaming_provider_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(StreamingProvider provider) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: StreamingProviderLogo(provider: provider)),
  );
}

void main() {
  testWidgets('a provider with a link is a tappable button', (tester) async {
    await tester.pumpWidget(_host(const StreamingProvider(
      name: 'Netflix',
      url: 'https://netflix.com/title/1',
    )));

    expect(find.byType(InkWell), findsOneWidget);
    expect(find.text('Netflix'), findsOneWidget);
    expect(tester.widget<InkWell>(find.byType(InkWell)).onTap, isNotNull);
  });

  testWidgets('a provider without a link is shown but not tappable',
      (tester) async {
    await tester.pumpWidget(_host(const StreamingProvider(name: 'Hulu')));

    expect(find.byType(InkWell), findsNothing);
    expect(find.text('Hulu'), findsOneWidget);
  });

  testWidgets('a rent option shows its price', (tester) async {
    await tester.pumpWidget(_host(const StreamingProvider(
      name: 'Amazon',
      url: 'https://amazon.com/x',
      offer: ProviderOffer.rent,
      price: 3.99,
    )));

    expect(find.text('Amazon'), findsOneWidget);
    expect(find.text(r'$3.99'), findsOneWidget);
  });
}
