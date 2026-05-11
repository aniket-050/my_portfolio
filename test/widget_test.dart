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
    expect(find.text('MY NAME'), findsOneWidget);
    expect(find.text('IS ANIKET'), findsOneWidget);
    expect(find.text('PARIHAR...'), findsOneWidget);
    expect(find.text("Let's talk with me"), findsOneWidget);
  });

  testWidgets('compact layout renders side rail navigation', (
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
    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    expect(find.text('WORKS'), findsWidgets);
    expect(find.text('CONTACT'), findsWidgets);
    expect(find.text('Download CV'), findsWidgets);
  });
}
