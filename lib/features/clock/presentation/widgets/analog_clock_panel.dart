import 'package:flutter/material.dart';

import 'package:lunadial/features/clock/domain/clock_layout.dart';
import 'package:lunadial/features/clock/presentation/widgets/analog_clock_face.dart';
import 'package:lunadial/features/clock/presentation/widgets/calendar_panel.dart';
import 'package:lunadial/l10n/app_localizations.dart';

class AnalogClockPanel extends StatelessWidget {
  const AnalogClockPanel({
    super.key,
    required this.currentTime,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.layout,
    required this.showSecondHand,
    required this.nightModeEnabled,
  });

  final DateTime currentTime;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onPageChanged;
  final AnalogClockLayoutSpec layout;
  final bool showSecondHand;
  final bool nightModeEnabled;

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;

    return Semantics(
      label: translations.analogClockSemantics,
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final effectiveLayout = _resolveEffectiveLayout(
              constraints: constraints,
              baseLayout: layout,
              focusedDay: focusedDay,
            );

            final clock = DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  width: nightModeEnabled ? 1.5 : 2,
                  color: nightModeEnabled
                      ? Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.45)
                      : Theme.of(context).colorScheme.outline,
                ),
                shape: BoxShape.circle,
              ),
              child: AnalogClockFace(
                time: currentTime,
                size: effectiveLayout.clockSize,
                showSecondHand: showSecondHand,
                nightModeEnabled: nightModeEnabled,
              ),
            );

            final calendar = Opacity(
              opacity: nightModeEnabled ? 0.58 : 1,
              child: SizedBox(
                width: effectiveLayout.calendarWidth,
                child: CalendarPanel(
                  focusedDay: focusedDay,
                  selectedDay: selectedDay,
                  onDaySelected: onDaySelected,
                  onPageChanged: onPageChanged,
                  density: effectiveLayout.calendarDensity,
                ),
              ),
            );

            final children = [
              clock,
              SizedBox(
                width: effectiveLayout.direction == Axis.horizontal
                    ? effectiveLayout.spacing
                    : 0,
                height: effectiveLayout.direction == Axis.vertical
                    ? effectiveLayout.spacing
                    : 0,
              ),
              calendar,
            ];

            return Padding(
              padding: effectiveLayout.padding,
              child: effectiveLayout.direction == Axis.horizontal
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: children,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: children,
                    ),
            );
          },
        ),
      ),
    );
  }
}

AnalogClockLayoutSpec _resolveEffectiveLayout({
  required BoxConstraints constraints,
  required AnalogClockLayoutSpec baseLayout,
  required DateTime focusedDay,
}) {
  final availableWidth = _axisExtent(
    constraints.maxWidth - baseLayout.padding.horizontal,
  );
  final availableHeight = _axisExtent(
    constraints.maxHeight - baseLayout.padding.vertical,
  );

  if (availableWidth <= 0 || availableHeight <= 0) {
    return baseLayout;
  }

  if (_fitsLayout(baseLayout, availableWidth, availableHeight, focusedDay)) {
    return baseLayout;
  }

  final regularVertical = _buildVerticalLayout(
    availableWidth: availableWidth,
    availableHeight: availableHeight,
    spacing: baseLayout.spacing,
    density: baseLayout.calendarDensity,
    preferredClockSize: baseLayout.clockSize,
    preferredCalendarWidth: baseLayout.calendarWidth,
    focusedDay: focusedDay,
    padding: baseLayout.padding,
  );
  if (_fitsLayout(
    regularVertical,
    availableWidth,
    availableHeight,
    focusedDay,
  )) {
    return regularVertical;
  }

  final compactVertical = _buildVerticalLayout(
    availableWidth: availableWidth,
    availableHeight: availableHeight,
    spacing: baseLayout.spacing,
    density: CalendarDensity.compact,
    preferredClockSize: baseLayout.clockSize,
    preferredCalendarWidth: baseLayout.calendarWidth,
    focusedDay: focusedDay,
    padding: baseLayout.padding,
  );
  if (_fitsLayout(
    compactVertical,
    availableWidth,
    availableHeight,
    focusedDay,
  )) {
    return compactVertical;
  }

  return compactVertical;
}

AnalogClockLayoutSpec _buildVerticalLayout({
  required double availableWidth,
  required double availableHeight,
  required double spacing,
  required CalendarDensity density,
  required double preferredClockSize,
  required double preferredCalendarWidth,
  required DateTime focusedDay,
  required EdgeInsets padding,
}) {
  final baseClockSize = _boundedSize(preferredClockSize, availableWidth);
  final baseCalendarWidth = _boundedSize(
    preferredCalendarWidth,
    availableWidth,
  );
  final baseSpacing = spacing.clamp(8.0, 24.0);
  final baseHeight =
      baseClockSize +
      baseSpacing +
      _estimateCalendarHeight(
        width: baseCalendarWidth,
        density: density,
        focusedDay: focusedDay,
      );
  final scale = baseHeight > availableHeight && baseHeight > 0
      ? (availableHeight / baseHeight).clamp(0.55, 1.0)
      : 1.0;

  final scaledClockSize = _boundedSize(baseClockSize * scale, availableWidth);
  final scaledCalendarWidth = _boundedSize(
    baseCalendarWidth * scale,
    availableWidth,
  );
  final scaledSpacing = (baseSpacing * scale).clamp(6.0, 24.0);

  return AnalogClockLayoutSpec(
    direction: Axis.vertical,
    padding: padding,
    clockSize: scaledClockSize,
    calendarWidth: scaledCalendarWidth,
    spacing: scaledSpacing,
    calendarDensity: density,
  );
}

bool _fitsLayout(
  AnalogClockLayoutSpec layout,
  double availableWidth,
  double availableHeight,
  DateTime focusedDay,
) {
  final calendarHeight = _estimateCalendarHeight(
    width: layout.calendarWidth,
    density: layout.calendarDensity,
    focusedDay: focusedDay,
  );

  if (layout.direction == Axis.horizontal) {
    final requiredWidth =
        layout.clockSize + layout.spacing + layout.calendarWidth;
    final requiredHeight = layout.clockSize > calendarHeight
        ? layout.clockSize
        : calendarHeight;
    return requiredWidth <= availableWidth && requiredHeight <= availableHeight;
  }

  final requiredWidth = layout.clockSize > layout.calendarWidth
      ? layout.clockSize
      : layout.calendarWidth;
  final requiredHeight = layout.clockSize + layout.spacing + calendarHeight;
  return requiredWidth <= availableWidth && requiredHeight <= availableHeight;
}

double _estimateCalendarHeight({
  required double width,
  required CalendarDensity density,
  required DateTime focusedDay,
}) {
  final cellSize = width / 7;
  final showWeekdayHeader = density == CalendarDensity.regular;
  final headerHeight = cellSize * (showWeekdayHeader ? 1.2 : 0.95);
  final weekRowHeight = showWeekdayHeader ? cellSize * 0.9 : 0.0;
  final firstDayOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
  final firstDayOfWeek = firstDayOfMonth.weekday - 1;
  final daysInMonth = DateUtils.getDaysInMonth(
    focusedDay.year,
    focusedDay.month,
  );
  final rowsNeeded = ((firstDayOfWeek + daysInMonth) / 7).ceil();

  return headerHeight + weekRowHeight + cellSize * rowsNeeded;
}

double _boundedSize(double preferred, double available) {
  if (available <= 0) {
    return available;
  }
  return preferred.clamp(0.0, available).toDouble();
}

double _axisExtent(double extent) {
  if (!extent.isFinite) {
    return 0;
  }
  return extent < 0 ? 0 : extent;
}
