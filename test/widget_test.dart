import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:my_portfolio/src/app.dart';

void main() {
  setUp(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  testWidgets('portfolio hero renders', (WidgetTester tester) async {
    await tester.pumpWidget(const PortfolioApp());
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Aniket Parihar'), findsWidgets);
    expect(
      find.text(
        'Flutter engineer building products around maps, motion and scale.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('mobile menu expands with resume action', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PortfolioApp());
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byIcon(Icons.menu_rounded), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsNothing);
    expect(find.widgetWithText(TextButton, 'Projects'), findsNothing);
    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Projects'), findsOneWidget);
  });
}
