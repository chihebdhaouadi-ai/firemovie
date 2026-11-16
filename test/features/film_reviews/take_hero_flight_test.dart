import 'package:film_wise_mobile/features/film_reviews/presentation/take_hero.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _tag = 'take';
const _body =
    'A long take that wraps over several lines so the card has real height '
    'and the flight has to re-layout its content at every frame of the zoom.';

class _Scope extends InheritedWidget {
  const _Scope({required super.child});

  static _Scope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Scope>()!;

  @override
  bool updateShouldNotify(_Scope oldWidget) => false;
}

class _SourceCard extends StatelessWidget {
  const _SourceCard();

  @override
  Widget build(BuildContext context) => const _Card(scoped: false);
}

class _DetailCard extends StatelessWidget {
  const _DetailCard();

  @override
  Widget build(BuildContext context) {
    _Scope.of(context);
    return const _Card(scoped: true);
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.scoped});

  final bool scoped;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                CircleAvatar(radius: 18),
                SizedBox(width: 12),
                Expanded(child: Text('leo')),
                Text('Loved'),
              ],
            ),
            const SizedBox(height: 12),
            const Text(_body),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            const Text('votes 3 well argued'),
          ],
        ),
      ),
    );
  }
}

void main() {
  testWidgets('hero flight does not need the detail scope', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: SizedBox(
                width: 260,
                child: Hero(
                  tag: _tag,
                  flightShuttleBuilder: takeHeroFlightShuttle,
                  child: const _SourceCard(),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => _Scope(
                    child: Scaffold(
                      body: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 640),
                          child: Hero(
                            tag: _tag,
                            flightShuttleBuilder: takeHeroFlightShuttle,
                            child: const _DetailCard(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    for (var ms = 0; ms <= 1000; ms += 50) {
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull, reason: 'at ${ms}ms');
    }
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
