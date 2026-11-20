import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:film_wise_mobile/features/home/views/widgets/horizontal_scroll_hint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('scroll hint appears only while more content is available',
      (tester) async {
    tester.view.physicalSize = const Size(300, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 280,
              child: HorizontalScrollHint(
                controller: controller,
                height: 100,
                child: ListView(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  children: const [
                    SizedBox(width: 250),
                    SizedBox(width: 250),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byIcon(BootstrapIcons.chevron_right), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.byIcon(BootstrapIcons.chevron_right), findsNothing);
  });
}
