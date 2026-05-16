import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lunadial/features/clock/presentation/widgets/analog_clock_face.dart';

void main() {
  testWidgets('analog clock face exposes painter with visible second hand', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnalogClockFace(
            time: DateTime(2026, 1, 1, 12, 34, 56),
            size: 240,
            showSecondHand: true,
            nightModeEnabled: false,
          ),
        ),
      ),
    );

    final handsPaint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(AnalogClockFace),
        matching: find.byType(CustomPaint),
      ).last,
    );
    final painter = handsPaint.painter! as AnalogClockHandsPainter;

    expect(painter.showSecondHand, isTrue);
  });

  testWidgets('analog clock face exposes painter without second hand', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnalogClockFace(
            time: DateTime(2026, 1, 1, 12, 34, 56),
            size: 240,
            showSecondHand: false,
            nightModeEnabled: true,
          ),
        ),
      ),
    );

    final handsPaint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(AnalogClockFace),
        matching: find.byType(CustomPaint),
      ).last,
    );
    final painter = handsPaint.painter! as AnalogClockHandsPainter;

    expect(painter.showSecondHand, isFalse);
    expect(painter.nightModeEnabled, isTrue);
  });
}
