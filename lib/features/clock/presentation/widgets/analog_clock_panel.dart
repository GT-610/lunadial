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
  });

  final DateTime currentTime;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onPageChanged;
  final AnalogClockLayoutSpec layout;

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;

    final clock = DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: Theme.of(context).colorScheme.outline,
        ),
        shape: BoxShape.circle,
      ),
      child: AnalogClockFace(time: currentTime, size: layout.clockSize),
    );

    final calendar = SizedBox(
      width: layout.calendarWidth,
      child: CalendarPanel(
        focusedDay: focusedDay,
        selectedDay: selectedDay,
        onDaySelected: onDaySelected,
        onPageChanged: onPageChanged,
        density: layout.calendarDensity,
      ),
    );

    final children = [
      clock,
      SizedBox(
        width: layout.direction == Axis.horizontal ? layout.spacing : 0,
        height: layout.direction == Axis.vertical ? layout.spacing : 0,
      ),
      calendar,
    ];

    return Semantics(
      label: translations.analogClockSemantics,
      child: Center(
        child: Padding(
          padding: layout.padding,
          child: layout.direction == Axis.horizontal
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
        ),
      ),
    );
  }
}
