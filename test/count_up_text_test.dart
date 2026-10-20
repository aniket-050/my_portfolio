import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_portfolio/src/core/widgets/count_up_text.dart';
import 'package:visibility_detector/visibility_detector.dart';

void main() {
  setUp(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  const values = ['08+', '60K+', '8.14', '4th', '10K+ downloads', 'CGPA: 8.14'];

  testWidgets('counts up to the exact original values', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Column(
          children: [for (final value in values) CountUpText(value)],
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Mid-animation the numbers are below their targets.
    expect(find.text('60K+'), findsNothing);

    await tester.pumpAndSettle();
    for (final value in values) {
      expect(find.text(value), findsOneWidget);
    }
  });

  testWidgets('shows values without a number unchanged', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CountUpText('Live on Google Play')),
    );
    expect(find.text('Live on Google Play'), findsOneWidget);
  });
}
