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
          ),
        ),
      ),
    );

    final customPaint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(AnalogClockFace),
        matching: find.byType(CustomPaint),
      ),
    );
    final painter = customPaint.painter! as AnalogClockPainter;

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
          ),
        ),
      ),
    );

    final customPaint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(AnalogClockFace),
        matching: find.byType(CustomPaint),
      ),
    );
    final painter = customPaint.painter! as AnalogClockPainter;

    expect(painter.showSecondHand, isFalse);
  });
}
