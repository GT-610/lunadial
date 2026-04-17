import 'package:flutter/material.dart';
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
    test('resolves viewport classes across common device sizes', () {
      expect(
        resolveClockViewportClass(const Size(320, 568)),
        ClockViewportClass.compactPhone,
      );
      expect(
        resolveClockViewportClass(const Size(390, 844)),
        ClockViewportClass.phone,
      );
      expect(
        resolveClockViewportClass(const Size(480, 900)),
        ClockViewportClass.largePhone,
      );
      expect(
        resolveClockViewportClass(const Size(800, 1280)),
        ClockViewportClass.tablet,
      );
      expect(
        resolveClockViewportClass(const Size(1440, 1024)),
        ClockViewportClass.largeWindow,
      );
    });

    test('uses compact vertical analog layout on very small phones', () {
      final spec = resolveAnalogClockLayout(const Size(320, 568));

      expect(spec.direction, Axis.vertical);
      expect(spec.calendarDensity, CalendarDensity.compact);
      expect(spec.clockSize, lessThan(300));
    });

    test('uses horizontal analog layout for tablets and larger windows', () {
      expect(
        resolveAnalogClockLayout(const Size(1280, 800)).direction,
        Axis.horizontal,
      );
      expect(
        resolveAnalogClockLayout(const Size(1440, 900)).direction,
        Axis.horizontal,
      );
    });

    test('analog layout stays valid for very narrow draggable windows', () {
      final spec = resolveAnalogClockLayout(const Size(1142, 320));

      expect(spec.clockSize, greaterThan(0));
      expect(spec.calendarWidth, greaterThan(0));
      expect(spec.calendarDensity, CalendarDensity.compact);
    });

    test(
      'resolves bounded digital layout specs for narrow and wide screens',
      () {
        final compact = resolveDigitalClockLayout(const Size(320, 568));
        final tablet = resolveDigitalClockLayout(const Size(1024, 768));

        expect(compact.timeFontSize, lessThan(tablet.timeFontSize));
        expect(compact.dateFontSize, lessThan(compact.timeFontSize));
        expect(tablet.maxContentWidth, greaterThan(compact.maxContentWidth));
      },
    );
  });
}
