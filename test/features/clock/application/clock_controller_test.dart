import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:lunadial/features/clock/application/clock_controller.dart';
import 'package:lunadial/features/clock/domain/clock_layout.dart';

void main() {
  group('ClockController', () {
    test('calculates delay until next second', () {
      final delay = ClockController.delayUntilNextSecond(
        DateTime(2026, 1, 1, 12, 0, 0, 250),
      );

      expect(delay.inMilliseconds, 750);
    });

    test('selectDay updates selected and focused day', () {
      final controller = ClockController(startTicker: false);
      final day = DateTime(2026, 4, 16);

      controller.selectDay(day);

      expect(controller.selectedDay, day);
      expect(controller.focusedDay, DateTime(2026, 4, 1));

      controller.dispose();
    });

    test('focusDay does not notify when month is unchanged', () {
      final controller = ClockController(
        startTicker: false,
        now: () => DateTime(2026, 4, 16, 12),
      );
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.focusDay(DateTime(2026, 4, 20));

      expect(notifications, 0);
      controller.dispose();
    });
  });

  group('clock layout', () {
    test('uses horizontal layout for landscape displays', () {
      expect(useHorizontalClockLayout(const Size(1200, 700)), isTrue);
    });

    test('uses vertical layout for compact portrait displays', () {
      expect(useHorizontalClockLayout(const Size(420, 800)), isFalse);
    });

    test('treats wide shortest side as tablet layout', () {
      expect(useHorizontalClockLayout(const Size(700, 700)), isTrue);
    });
  });
}
