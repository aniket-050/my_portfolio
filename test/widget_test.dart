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

  testWidgets('responsive portfolio layouts render without overflow', (
    WidgetTester tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final sizes = <Size>[
      const Size(1440, 900),
      const Size(1280, 800),
      const Size(1024, 768),
      const Size(768, 1024),
      const Size(430, 932),
    ];

    for (final size in sizes) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(const PortfolioApp());
      await tester.pump(const Duration(milliseconds: 250));

      expect(
        tester.takeException(),
        isNull,
        reason: 'Expected no layout exception at ${size.width}x${size.height}',
      );
    }
  });

  testWidgets('admin panel unlocks and contact page renders', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    tester.binding.platformDispatcher.defaultRouteNameTestValue = '/admin';
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.binding.platformDispatcher.clearAllTestValues);

    await tester.pumpWidget(const PortfolioApp());
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byTooltip('Admin Panel'), findsNothing);
    expect(find.text('Portfolio Admin'), findsOneWidget);
    expect(find.text('Admin email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    Navigator.of(
      tester.element(find.text('Portfolio Admin')),
    ).pushNamed('/contact-us');
    await tester.pumpAndSettle();

    expect(find.text('Contact Us'), findsOneWidget);
    expect(find.text('Send Message'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
