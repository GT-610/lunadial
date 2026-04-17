import 'package:flutter/widgets.dart';

enum ClockViewportClass { compactPhone, phone, largePhone, tablet, largeWindow }

enum CalendarDensity { compact, regular }

@immutable
class DigitalClockLayoutSpec {
  const DigitalClockLayoutSpec({
    required this.padding,
    required this.maxContentWidth,
    required this.timeFontSize,
    required this.dateFontSize,
    required this.verticalSpacing,
  });

  final EdgeInsets padding;
  final double maxContentWidth;
  final double timeFontSize;
  final double dateFontSize;
  final double verticalSpacing;
}

@immutable
class AnalogClockLayoutSpec {
  const AnalogClockLayoutSpec({
    required this.direction,
    required this.padding,
    required this.clockSize,
    required this.calendarWidth,
    required this.spacing,
    required this.calendarDensity,
  });

  final Axis direction;
  final EdgeInsets padding;
  final double clockSize;
  final double calendarWidth;
  final double spacing;
  final CalendarDensity calendarDensity;
}

ClockViewportClass resolveClockViewportClass(Size size) {
  final shortest = size.shortestSide;
  if (shortest < 360) {
    return ClockViewportClass.compactPhone;
  }
  if (shortest < 480) {
    return ClockViewportClass.phone;
  }
  if (shortest < 600) {
    return ClockViewportClass.largePhone;
  }
  if (shortest < 900) {
    return ClockViewportClass.tablet;
  }
  return ClockViewportClass.largeWindow;
}

DigitalClockLayoutSpec resolveDigitalClockLayout(Size size) {
  final viewport = resolveClockViewportClass(size);
  final width = size.width;
  final height = size.height;
  final shortest = size.shortestSide;

  switch (viewport) {
    case ClockViewportClass.compactPhone:
      final timeFontSize = (shortest * 0.31).clamp(40.0, 82.0);
      return DigitalClockLayoutSpec(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        maxContentWidth: (width - 24).clamp(120.0, 420.0),
        timeFontSize: timeFontSize,
        dateFontSize: (timeFontSize * 0.3).clamp(14.0, 24.0),
        verticalSpacing: 8,
      );
    case ClockViewportClass.phone:
      final timeFontSize = (shortest * 0.34).clamp(56.0, 110.0);
      return DigitalClockLayoutSpec(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        maxContentWidth: (width - 32).clamp(200.0, 520.0),
        timeFontSize: timeFontSize,
        dateFontSize: (timeFontSize * 0.3).clamp(18.0, 34.0),
        verticalSpacing: 10,
      );
    case ClockViewportClass.largePhone:
      final timeFontSize = (shortest * 0.37).clamp(72.0, 140.0);
      return DigitalClockLayoutSpec(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        maxContentWidth: (width - 48).clamp(260.0, 620.0),
        timeFontSize: timeFontSize,
        dateFontSize: (timeFontSize * 0.28).clamp(22.0, 40.0),
        verticalSpacing: 12,
      );
    case ClockViewportClass.tablet:
      final timeFontSize = (shortest * 0.34).clamp(96.0, 190.0);
      return DigitalClockLayoutSpec(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        maxContentWidth: (width * 0.8).clamp(480.0, 900.0),
        timeFontSize: timeFontSize,
        dateFontSize: (timeFontSize * 0.26).clamp(28.0, 52.0),
        verticalSpacing: 16,
      );
    case ClockViewportClass.largeWindow:
      final timeFontSize = (height * 0.26).clamp(120.0, 240.0);
      return DigitalClockLayoutSpec(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        maxContentWidth: (width * 0.7).clamp(640.0, 1100.0),
        timeFontSize: timeFontSize,
        dateFontSize: (timeFontSize * 0.25).clamp(32.0, 60.0),
        verticalSpacing: 18,
      );
  }
}

AnalogClockLayoutSpec resolveAnalogClockLayout(Size size) {
  final viewport = resolveClockViewportClass(size);
  final width = size.width;
  final height = size.height;

  switch (viewport) {
    case ClockViewportClass.compactPhone:
      final padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 16);
      return AnalogClockLayoutSpec(
        direction: Axis.vertical,
        padding: padding,
        clockSize: (width - padding.horizontal).clamp(180.0, height * 0.48),
        calendarWidth: (width - padding.horizontal).clamp(180.0, 280.0),
        spacing: 12,
        calendarDensity: CalendarDensity.compact,
      );
    case ClockViewportClass.phone:
      final padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 20);
      return AnalogClockLayoutSpec(
        direction: Axis.vertical,
        padding: padding,
        clockSize: (width - padding.horizontal).clamp(240.0, height * 0.52),
        calendarWidth: (width - padding.horizontal).clamp(220.0, 320.0),
        spacing: 16,
        calendarDensity: CalendarDensity.compact,
      );
    case ClockViewportClass.largePhone:
      final useHorizontal = width > height * 1.15;
      final padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 24);
      return AnalogClockLayoutSpec(
        direction: useHorizontal ? Axis.horizontal : Axis.vertical,
        padding: padding,
        clockSize: useHorizontal
            ? (height * 0.68).clamp(260.0, width * 0.42)
            : (width - padding.horizontal).clamp(280.0, height * 0.5),
        calendarWidth: useHorizontal
            ? (width * 0.32).clamp(240.0, 360.0)
            : (width - padding.horizontal).clamp(240.0, 360.0),
        spacing: 20,
        calendarDensity: CalendarDensity.regular,
      );
    case ClockViewportClass.tablet:
      final padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 28);
      return AnalogClockLayoutSpec(
        direction: Axis.horizontal,
        padding: padding,
        clockSize: (height * 0.66).clamp(320.0, width * 0.42),
        calendarWidth: (width * 0.34).clamp(280.0, 420.0),
        spacing: 24,
        calendarDensity: CalendarDensity.regular,
      );
    case ClockViewportClass.largeWindow:
      final padding = const EdgeInsets.symmetric(horizontal: 36, vertical: 32);
      return AnalogClockLayoutSpec(
        direction: Axis.horizontal,
        padding: padding,
        clockSize: (height * 0.7).clamp(360.0, width * 0.38),
        calendarWidth: (width * 0.28).clamp(320.0, 460.0),
        spacing: 28,
        calendarDensity: CalendarDensity.regular,
      );
  }
}

bool useHorizontalClockLayout(Size size) =>
    resolveAnalogClockLayout(size).direction == Axis.horizontal;
