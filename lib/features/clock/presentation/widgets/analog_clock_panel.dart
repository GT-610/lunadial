import 'package:flutter/material.dart';

import 'package:lunadial/features/clock/domain/clock_layout.dart';
import 'package:lunadial/features/clock/presentation/widgets/analog_clock_face.dart';
import 'package:lunadial/features/clock/presentation/widgets/calendar_panel.dart';
import 'package:lunadial/l10n/app_localizations.dart';

class AnalogClockPanel extends StatefulWidget {
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
  State<AnalogClockPanel> createState() => _AnalogClockPanelState();
}

class _AnalogClockPanelState extends State<AnalogClockPanel> {
  Widget? _calendarWidget;
  AnalogClockLayoutSpec? _effectiveLayout;
  BoxConstraints? _lastConstraints;
  DateTime? _today;

  bool _calendarDepsChanged(AnalogClockPanel oldWidget) {
    return !identical(oldWidget.focusedDay, widget.focusedDay) ||
        !identical(oldWidget.selectedDay, widget.selectedDay) ||
        !identical(oldWidget.layout, widget.layout) ||
        oldWidget.nightModeEnabled != widget.nightModeEnabled ||
        !identical(oldWidget.onDaySelected, widget.onDaySelected) ||
        !identical(oldWidget.onPageChanged, widget.onPageChanged);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _rebuildCalendar() {
    if (_lastConstraints == null) return;
    _today = DateTime.now();
    _effectiveLayout = _resolveEffectiveLayout(
      constraints: _lastConstraints!,
      baseLayout: widget.layout,
      focusedDay: widget.focusedDay,
    );
    _calendarWidget = Opacity(
      opacity: widget.nightModeEnabled ? 0.58 : 1,
      child: SizedBox(
        width: _effectiveLayout!.calendarWidth,
        child: CalendarPanel(
          focusedDay: widget.focusedDay,
          selectedDay: widget.selectedDay,
          onDaySelected: widget.onDaySelected,
          onPageChanged: widget.onPageChanged,
          density: _effectiveLayout!.calendarDensity,
          today: _today!,
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant AnalogClockPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final now = DateTime.now();
    if (_today == null || !_isSameDay(_today!, now)) {
      _rebuildCalendar();
    } else if (_calendarDepsChanged(oldWidget)) {
      _rebuildCalendar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;

    return Semantics(
      label: translations.analogClockSemantics,
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final constraintsChanged =
                _lastConstraints == null ||
                _lastConstraints!.maxWidth != constraints.maxWidth ||
                _lastConstraints!.maxHeight != constraints.maxHeight;
            _lastConstraints = constraints;

            if (_effectiveLayout == null || constraintsChanged) {
              _effectiveLayout = _resolveEffectiveLayout(
                constraints: constraints,
                baseLayout: widget.layout,
                focusedDay: widget.focusedDay,
              );
              _rebuildCalendar();
            }

            final clock = DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  width: widget.nightModeEnabled ? 1.5 : 2,
                  color: widget.nightModeEnabled
                      ? Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.45)
                      : Theme.of(context).colorScheme.outline,
                ),
                shape: BoxShape.circle,
              ),
              child: AnalogClockFace(
                time: widget.currentTime,
                size: _effectiveLayout!.clockSize,
                showSecondHand: widget.showSecondHand,
                nightModeEnabled: widget.nightModeEnabled,
              ),
            );

            final children = [
              clock,
              SizedBox(
                width: _effectiveLayout!.direction == Axis.horizontal
                    ? _effectiveLayout!.spacing
                    : 0,
                height: _effectiveLayout!.direction == Axis.vertical
                    ? _effectiveLayout!.spacing
                    : 0,
              ),
              _calendarWidget!,
            ];

            return Padding(
              padding: _effectiveLayout!.padding,
              child: _effectiveLayout!.direction == Axis.horizontal
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

  final sameDirectionFallback = baseLayout.direction == Axis.horizontal
      ? _buildHorizontalLayout(
          availableWidth: availableWidth,
          availableHeight: availableHeight,
          spacing: baseLayout.spacing,
          density: baseLayout.calendarDensity,
          preferredClockSize: baseLayout.clockSize,
          preferredCalendarWidth: baseLayout.calendarWidth,
          focusedDay: focusedDay,
          padding: baseLayout.padding,
        )
      : _buildVerticalLayout(
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
    sameDirectionFallback,
    availableWidth,
    availableHeight,
    focusedDay,
  )) {
    return sameDirectionFallback;
  }

  final oppositeDirectionFallback = baseLayout.direction == Axis.horizontal
      ? _buildVerticalLayout(
          availableWidth: availableWidth,
          availableHeight: availableHeight,
          spacing: baseLayout.spacing,
          density: baseLayout.calendarDensity,
          preferredClockSize: baseLayout.clockSize,
          preferredCalendarWidth: baseLayout.calendarWidth,
          focusedDay: focusedDay,
          padding: baseLayout.padding,
        )
      : _buildHorizontalLayout(
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
    oppositeDirectionFallback,
    availableWidth,
    availableHeight,
    focusedDay,
  )) {
    return oppositeDirectionFallback;
  }

  final compactFallback = _buildVerticalLayout(
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
    compactFallback,
    availableWidth,
    availableHeight,
    focusedDay,
  )) {
    return compactFallback;
  }

  return compactFallback;
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

AnalogClockLayoutSpec _buildHorizontalLayout({
  required double availableWidth,
  required double availableHeight,
  required double spacing,
  required CalendarDensity density,
  required double preferredClockSize,
  required double preferredCalendarWidth,
  required DateTime focusedDay,
  required EdgeInsets padding,
}) {
  final baseSpacing = spacing.clamp(8.0, 24.0);
  final baseClockSize = _boundedSize(preferredClockSize, availableHeight);
  final baseCalendarWidth = _boundedSize(
    preferredCalendarWidth,
    availableWidth - baseClockSize - baseSpacing,
  );
  final calendarHeight = _estimateCalendarHeight(
    width: baseCalendarWidth,
    density: density,
    focusedDay: focusedDay,
  );
  final requiredWidth = baseClockSize + baseSpacing + baseCalendarWidth;
  final requiredHeight = baseClockSize > calendarHeight
      ? baseClockSize
      : calendarHeight;
  final scale =
      (requiredWidth > availableWidth || requiredHeight > availableHeight) &&
          requiredWidth > 0 &&
          requiredHeight > 0
      ? (availableWidth / requiredWidth < availableHeight / requiredHeight
                ? availableWidth / requiredWidth
                : availableHeight / requiredHeight)
            .clamp(0.55, 1.0)
      : 1.0;

  final scaledSpacing = (baseSpacing * scale).clamp(6.0, 24.0);
  final scaledClockSize = _boundedSize(baseClockSize * scale, availableHeight);
  final scaledCalendarWidth = _boundedSize(
    baseCalendarWidth * scale,
    availableWidth - scaledClockSize - scaledSpacing,
  );

  return AnalogClockLayoutSpec(
    direction: Axis.horizontal,
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
    return 0.0;
  }
  return preferred.clamp(0.0, available).toDouble();
}

double _axisExtent(double extent) {
  if (!extent.isFinite) {
    return 0;
  }
  return extent < 0 ? 0 : extent;
}
