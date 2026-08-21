import 'package:flutter/material.dart';

import 'package:lunadial/features/clock/application/clock_controller.dart';
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
    return oldWidget.focusedDay != widget.focusedDay ||
        oldWidget.selectedDay != widget.selectedDay ||
        !identical(oldWidget.layout, widget.layout) ||
        oldWidget.nightModeEnabled != widget.nightModeEnabled ||
        oldWidget.onDaySelected != widget.onDaySelected ||
        oldWidget.onPageChanged != widget.onPageChanged;
  }

  void _rebuildCalendar() {
    if (_lastConstraints == null) return;
    _today = DateUtils.dateOnly(widget.currentTime);
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
    if (!ClockController.isSameDay(_today, widget.currentTime)) {
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

  if (baseLayout.direction == Axis.horizontal) {
    return _buildHorizontalLayout(
      availableWidth: availableWidth,
      availableHeight: availableHeight,
      spacing: baseLayout.spacing,
      density: baseLayout.calendarDensity,
      preferredClockSize: baseLayout.clockSize,
      focusedDay: focusedDay,
      padding: baseLayout.padding,
    );
  }

  if (_fitsLayout(baseLayout, availableWidth, availableHeight, focusedDay)) {
    return baseLayout;
  }

  final sameDirectionFallback = _buildVerticalLayout(
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

  final oppositeDirectionFallback = _buildHorizontalLayout(
    availableWidth: availableWidth,
    availableHeight: availableHeight,
    spacing: baseLayout.spacing,
    density: baseLayout.calendarDensity,
    preferredClockSize: baseLayout.clockSize,
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
  required DateTime focusedDay,
  required EdgeInsets padding,
}) {
  final baseSpacing = spacing.clamp(8.0, 24.0);
  final baseClockSize = _boundedSize(preferredClockSize, availableHeight);
  final baseCalendarWidth = _boundedSize(
    _calendarWidthForHeight(
      height: baseClockSize,
      density: density,
      focusedDay: focusedDay,
    ),
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
  return width *
      _calendarHeightFactor(density: density, focusedDay: focusedDay);
}

double _calendarWidthForHeight({
  required double height,
  required CalendarDensity density,
  required DateTime focusedDay,
}) {
  final heightFactor = _calendarHeightFactor(
    density: density,
    focusedDay: focusedDay,
  );
  return heightFactor > 0 ? height / heightFactor : 0;
}

double _calendarHeightFactor({
  required CalendarDensity density,
  required DateTime focusedDay,
}) {
  final isRegularDensity = density == CalendarDensity.regular;
  final firstDayOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
  final firstDayOfWeek = firstDayOfMonth.weekday % DateTime.daysPerWeek;
  final daysInMonth = DateUtils.getDaysInMonth(
    focusedDay.year,
    focusedDay.month,
  );
  final rowsNeeded = ((firstDayOfWeek + daysInMonth) / 7).ceil();

  final headerUnits = isRegularDensity ? 1.45 : 1.15;
  final weekHeaderUnits = isRegularDensity ? 0.75 : 0.62;
  return (headerUnits + weekHeaderUnits + rowsNeeded) / 7;
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
